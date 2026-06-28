//
//  View+SectionIndex.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//
import SwiftUI

// MARK: - View Extension

extension View {
    func sectionIndexWith(label: String) -> some View {
        modifier(SectionIndexModifier(label: label))
    }
}

// MARK: - View Modifier

/// ViewModifier to apply sectionIndexLabel only on iOS 26+
private struct SectionIndexModifier: ViewModifier {
    let label: String
    
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, *) {
            content.sectionIndexLabel(label)
        } else {
            content
        }
    }
}
