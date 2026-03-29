import Foundation

protocol WorkoutSessionRepositoryProtocol: Sendable {
    func fetchAll(for mesocycle: Mesocycle) async throws -> [WorkoutSession]
    func fetchInProgress() async throws -> WorkoutSession?

    func save(_ session: WorkoutSession) async throws
    func delete(_ session: WorkoutSession) async throws

    func addSet(_ set: LoggedSet, to session: WorkoutSession) async throws
    func deleteSet(_ set: LoggedSet) async throws
}
