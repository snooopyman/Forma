//
//  GymIconRainView.swift
//  Forma
//
//  Created by Armando Cáceres on 3/7/26.
//

import SwiftUI

struct GymIconRainView: View {
    
    // MARK: - Private Properties
    
    private let pieces: [Piece]
    private let totalDuration: Double
    
    // MARK: - States
    
    @State private var isVisible = true
    
    // MARK: - Initializers
    
    init(pieceCount: Int = 26) {
        let symbolNames = ["dumbbell.fill", "figure.strengthtraining.traditional", "trophy.fill", "flame.fill"]
        let colors: [Color] = [.accent, .success, .warning]
        
        pieces = (0..<pieceCount).map { _ in
            Piece(
                symbolName: symbolNames.randomElement() ?? "dumbbell.fill",
                color: colors.randomElement() ?? .accent,
                xFraction: .random(in: 0.05...0.95),
                delay: .random(in: 0...0.5),
                fallDuration: .random(in: 2.0...3.2),
                rotationDegrees: .random(in: -240...240),
                scale: .random(in: 0.75...1.3)
            )
        }
        totalDuration = (pieces.map { $0.delay + $0.fallDuration }.max() ?? 0) + 0.4
    }
    
    // MARK: - Body
    
    var body: some View {
        if isVisible {
            GeometryReader { proxy in
                ZStack {
                    ForEach(pieces) { piece in
                        FallingIconView(piece: piece, containerSize: proxy.size)
                    }
                }
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()
            .task {
                try? await Task.sleep(for: .seconds(totalDuration))
                isVisible = false
            }
        }
    }
}

// MARK: - Piece

private struct Piece: Identifiable {
    let id = UUID()
    let symbolName: String
    let color: Color
    let xFraction: CGFloat
    let delay: Double
    let fallDuration: Double
    let rotationDegrees: Double
    let scale: CGFloat
}

// MARK: - FallingIconView

private struct FallingIconView: View {
    
    // MARK: - Properties
    
    let piece: Piece
    let containerSize: CGSize
    
    // MARK: - States
    
    @State private var offsetY: CGFloat = -60
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    // MARK: - Body
    
    var body: some View {
        Image(systemName: piece.symbolName)
            .font(.system(size: 24 * piece.scale, weight: .semibold))
            .foregroundStyle(piece.color)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .position(x: piece.xFraction * containerSize.width, y: offsetY)
            .task {
                try? await Task.sleep(for: .seconds(piece.delay))
                withAnimation(.easeIn(duration: piece.fallDuration)) {
                    offsetY = containerSize.height + 60
                    rotation = piece.rotationDegrees
                }
                withAnimation(.easeIn(duration: piece.fallDuration * 0.3).delay(piece.fallDuration * 0.7)) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Previews

#Preview {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        GymIconRainView()
    }
}
