# Spec: Notificaciones locales reales

## Resumen
Notificaciones del sistema (`UserNotifications`) para recordatorios que hoy solo existen como banner pasivo dentro de la app, para que el usuario reciba el aviso aunque no tenga Forma abierta.

## Problema que resuelve
`DashboardInteractor.shouldShowMeasurementReminder()` (`Forma/Features/Dashboard/Interactor/DashboardInteractor.swift`) es un booleano puro que solo se evalúa si el usuario abre la app — si no la abre, nunca se entera de que "toca medición" el lunes o que lleva 6+ días sin registrar. No existe ninguna referencia a `UserNotifications`/`UNUserNotificationCenter` en todo el proyecto.

## Flujo principal
1. El sistema pide permiso de notificaciones (`UNUserNotificationCenter.current().requestAuthorization`) durante el **onboarding** (`Forma/Features/Onboarding/`), como un paso más junto a la configuración de perfil — no bloqueante, el usuario puede denegar y seguir con el setup
2. Si el usuario acepta, se programa el recordatorio con el default: **sábado 9:00 AM**
3. En Settings, el mismo toggle (patrón similar a "Export workouts to Health") permite activar/desactivar más adelante y, si está activo, muestra el selector de día de la semana + hora para reconfigurar la preferencia en cualquier momento
4. Si el usuario denegó el permiso en onboarding, el toggle en Settings al activarlo debe volver a pedir permiso (o, si el sistema ya lo denegó permanentemente, mostrar guía para activarlo desde Ajustes del sistema — mismo patrón que HealthKit)
5. Se programa una notificación local **no repetitiva** (`UNCalendarNotificationTrigger(dateMatching:, repeats: false)`) para la próxima ocurrencia del día/hora elegidos. No se usa `repeats: true`: una notificación local no puede mutar ni suprimirse en el momento de entrega (a diferencia del push remoto, no hay extensión que intercepte el contenido), así que la única forma de evitar redundancia con el banner es reprogramar la instancia individual cada vez que cambian las condiciones:
   - Al pasar la app a foreground (`scenePhase == .active`)
   - Al guardar una nueva `BodyMeasurement`
   - Al cambiar la preferencia de día/hora en Settings

   En cada uno de esos puntos: cancelar la notificación pendiente y reprogramar la próxima ocurrencia solo si `shouldShowMeasurementReminder`-equivalente sigue aplicando para esa fecha futura; si el usuario ya midió esta semana, no se programa nada hasta el próximo ciclo.
6. El usuario recibe la notificación en Lock Screen/Notification Center aunque la app esté cerrada
7. Al tocarla, abre la app en la pantalla de New Measurement

## Flujos alternativos
- Usuario deniega permiso → el banner pasivo actual sigue funcionando igual que hoy (no se pierde nada, solo no hay push)
- Usuario revoca permiso desde Ajustes del sistema → la app debe detectarlo (`UNUserNotificationCenter.current().notificationSettings()`) y reflejar el toggle apagado en Settings, sin crashear al intentar programar
- App en background al llegar la hora programada → el sistema entrega la notificación igual (no depende de que la app esté corriendo, son notificaciones locales programadas, no push remoto)

## Casos edge
- [x] Límite del sistema de 64 notificaciones locales pendientes por app — resuelto: al usar una única notificación no repetitiva reprogramada bajo demanda, el consumo es de 1 solo slot, muy lejos del límite
- [ ] Si el usuario cambia la fecha del sistema o de zona horaria, ¿la próxima ocurrencia programada se recalcula correctamente la próxima vez que la app pasa a foreground? (al no depender de `repeats: true`, basta con reprogramar en cada `scenePhase == .active`, pero hay que verificarlo con cambio manual de reloj/zona en simulador)
- [ ] Si el usuario mide el mismo día en que se cumple el disparo pero *después* de la hora programada (ej. mide a las 20:00 tras recibir la notificación de las 9:00 AM), ¿se cancela igual la siguiente reprogramación aunque la notificación de hoy ya se haya entregado?
- [ ] CloudKit sync entre dispositivos: las notificaciones NO se sincronizan (son locales por dispositivo). Como la reprogramación ocurre en cada foreground/al guardar medición, un dispositivo B debería auto-corregirse la próxima vez que se abra o se guarde una medición en él — pero mientras B no se abra, puede llegar una notificación redundante si la medición se registró en A. Aceptar esto como limitación conocida (ver "Lo que NO hace") en vez de intentar sincronizar el estado del `NotificationService` vía CloudKit

## Criterios de aceptación
- [ ] Nuevo `NotificationServiceProtocol` + `NotificationService` + `MockNotificationService`, mismo patrón que `HealthKitServiceProtocol`
- [ ] `AppContainer` expone `notificationService: NotificationServiceProtocol`
- [ ] Toggle en Settings para activar/desactivar, con manejo de permiso denegado sin crash
- [ ] Selector de día de la semana + hora en Settings junto al toggle, default **sábado 9:00 AM**, persistido (ej. `@AppStorage` o `UserProfile`) y editable en cualquier momento
- [ ] Lógica de "¿corresponde recordatorio esta semana?" extraída a un método compartido y reutilizado tanto por `shouldShowMeasurementReminder` (banner, evalúa "ahora") como por el scheduler de notificaciones (evalúa "para la próxima fecha programada") — no se duplica el criterio de negocio, pero tampoco se asume que ambos evalúan literalmente la misma función sin adaptar la fecha de referencia
- [ ] La notificación pendiente se cancela y reprograma (no repetitiva) en: foreground de la app, guardado de una nueva `BodyMeasurement`, y cambio de la preferencia de día/hora
- [ ] El banner pasivo del Dashboard sigue existiendo sin cambios — esta feature es aditiva, no lo reemplaza

## Lo que NO hace
- No es push remoto — son notificaciones locales programadas en el dispositivo, sin servidor
- No reemplaza el banner de Dashboard — ambos coexisten
- No incluye recordatorio de entreno según `WorkoutDay` — cada usuario ya tiene su propia rutina y horario de entreno establecido, un recordatorio genérico de la app sería redundante
- No incluye notificaciones de nutrición (recordatorio de comida) en esta primera versión

## Capas afectadas
- [ ] Data (`NotificationService` nuevo en `Data/Services/`)
- [ ] Domain (protocolo `NotificationServiceProtocol` en `Domain/Repositories/` o carpeta equivalente de servicios)
- [ ] Features
  - Onboarding: nuevo paso que solicita el permiso de notificaciones (`Forma/Features/Onboarding/`)
  - Settings: ViewModel/Interactor para el toggle + selector de día/hora
  - Dashboard Interactor y el scheduler comparten la lógica de "¿corresponde recordatorio?"
  - Reprogramación disparada desde `scenePhase` en `AppRootView`/`FormaApp` y desde el guardado de `NewMeasurement`
- [ ] App (`AppContainer` expone el nuevo servicio)
- [ ] Resources (Localizable.xcstrings para textos de la notificación y del nuevo paso de onboarding)

## Preguntas abiertas
Ninguna pendiente — decisiones cerradas:
- Hora: **configurable** (día de la semana + hora), default sábado 9:00 AM
- Alcance: **solo medición semanal**, sin recordatorio de entreno
- Permiso: se pide en **onboarding**, y el toggle + selector día/hora quedan disponibles en Settings para reconfigurar o reactivar en cualquier momento
