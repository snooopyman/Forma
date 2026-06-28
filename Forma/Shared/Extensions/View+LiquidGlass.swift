//
//  View+LiquidGlass.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//
import SwiftUI

// MARK: - View Extension

extension View {
    /// Applies backgroundExtensionEffect only on iOS 26+
    ///
    /// This modifier enables the Liquid Glass effect for background images,
    /// allowing them to extend beyond their frame boundaries seamlessly.
    /// Falls back to no-op on iOS 18.
    func liquidGlassBackground() -> some View {
        modifier(LiquidGlassBackgroundModifier())
    }
}

// MARK: - View Modifier

/// ViewModifier to apply backgroundExtensionEffect only on iOS 26+, macOS 26+
private struct LiquidGlassBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, *) {
            content.backgroundExtensionEffect()
        } else {
            content
        }
    }
}
