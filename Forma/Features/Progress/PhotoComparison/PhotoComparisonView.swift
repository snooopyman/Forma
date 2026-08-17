//
//  PhotoComparisonView.swift
//  Forma
//
//  Created by Armando Cáceres on 12/8/26.
//

import SwiftData
import SwiftUI
import UIKit

struct PhotoComparisonView: View {
    
    // MARK: - Private Properties
    
    private enum ComparisonSide: String, Identifiable {
        case before, after
        var id: String { rawValue }
    }
    
    // MARK: - States
    
    @State private var viewModel: PhotoComparisonViewModel
    @State private var dividerPosition: CGFloat = 0.5
    @State private var shareImage: Image?
    @State private var pickerSide: ComparisonSide?
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.displayScale) private var displayScale
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Computed Properties
    
    private var shareImageKey: String {
        [
            viewModel.beforePhoto.id.uuidString,
            viewModel.afterPhoto.id.uuidString,
            viewModel.beforeMeasurement?.id.uuidString ?? "-",
            viewModel.afterMeasurement?.id.uuidString ?? "-"
        ].joined(separator: "|")
    }
    
    // MARK: - Initializers
    
    init(photos: [ProgressPhoto], measurementRepository: BodyMeasurementRepositoryProtocol) {
        let interactor = PhotoComparisonInteractor(measurementRepository: measurementRepository)
        _viewModel = State(initialValue: PhotoComparisonViewModel(interactor: interactor, photos: photos))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: DS.Spacing.lg) {
                    sliderSection
                    measurementsSection
                    pickerButtonsRow
                }
                .padding(DS.Spacing.lg)
            }
            .navigationTitle(String(localized: "Compare photos"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Done")) { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let shareImage {
                        ShareLink(
                            item: shareImage,
                            preview: SharePreview(String(localized: "Photo comparison"), image: shareImage)
                        ) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
        }
        .task { await viewModel.loadMeasurements() }
        .task(id: shareImageKey) { updateShareImage() }
        .sheet(item: $pickerSide) { side in
            let opposite = side == .before ? viewModel.afterPhoto : viewModel.beforePhoto
            PhotoPickerSheet(
                photos: viewModel.allPhotos.filter { $0.angle == opposite.angle },
                excluding: opposite,
                title: side == .before ? String(localized: "Before") : String(localized: "After")
            ) { photo in
                Task {
                    if side == .before {
                        await viewModel.selectBefore(photo)
                    } else {
                        await viewModel.selectAfter(photo)
                    }
                }
            }
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var sliderSection: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                photoImage(viewModel.afterPhoto)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                
                photoImage(viewModel.beforePhoto)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .mask(alignment: .leading) {
                        Rectangle().frame(width: geo.size.width * dividerPosition)
                    }
                
                dividerHandle(width: geo.size.width, height: geo.size.height)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let fraction = value.location.x / geo.size.width
                        dividerPosition = min(max(fraction, 0), 1)
                    }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))
    }
    
    @ViewBuilder
    private func photoImage(_ photo: ProgressPhoto) -> some View {
        if let uiImage = UIImage(data: photo.imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Color.backgroundSecondary
        }
    }
    
    private func dividerHandle(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(.white)
                .frame(width: 2, height: height)
            Circle()
                .fill(.white)
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: "chevron.left.and.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.black)
                }
                .shadow(radius: 2)
        }
        .position(x: width * dividerPosition, y: height / 2)
        .accessibilityElement()
        .accessibilityLabel(String(localized: "Comparison divider"))
        .accessibilityValue(Text(Double(dividerPosition).formatted(.percent.precision(.fractionLength(0)))))
        .accessibilityAdjustableAction { direction in
            let step: CGFloat = 0.05
            switch direction {
            case .increment: dividerPosition = min(dividerPosition + step, 1)
            case .decrement: dividerPosition = max(dividerPosition - step, 0)
            @unknown default: break
            }
        }
    }
    
    @ViewBuilder
    private var measurementsSection: some View {
        if viewModel.beforeMeasurement != nil && viewModel.afterMeasurement != nil {
            HStack {
                weightColumn(label: String(localized: "Before"), measurement: viewModel.beforeMeasurement)
                deltaBadge
                weightColumn(label: String(localized: "After"), measurement: viewModel.afterMeasurement)
            }
        } else {
            Text(String(localized: "No weight data near these photos"))
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
    }
    
    private func weightColumn(label: String, measurement: BodyMeasurement?) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.textSecondary)
            if let measurement {
                Text(verbatim: "\(measurement.weightKg.formatted(.number.precision(.fractionLength(1)))) kg")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var deltaBadge: some View {
        if let delta = viewModel.weightDelta, delta != 0 {
            let isPositive = delta > 0
            HStack(spacing: 2) {
                Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                    .font(.caption2)
                Text(verbatim: abs(delta).formatted(.number.precision(.fractionLength(1))))
                    .font(.caption2)
            }
            .foregroundStyle(isPositive ? Color.success : Color.error)
        }
    }
    
    private var pickerButtonsRow: some View {
        HStack(spacing: DS.Spacing.md) {
            Button {
                pickerSide = .before
            } label: {
                Text(String(localized: "Before"))
                    .glassButtonLabel()
            }
            .buttonStyle(.glass)
            
            Button {
                withAnimation(reduceMotion ? nil : .default) {
                    viewModel.swapPhotos()
                }
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .frame(width: DS.Sizing.minTapTarget, height: DS.Sizing.minTapTarget)
            }
            .buttonStyle(.glass)
            .sensoryFeedback(.selection, trigger: viewModel.swapCount)
            .accessibilityLabel(String(localized: "Swap"))
            
            Button {
                pickerSide = .after
            } label: {
                Text(String(localized: "After"))
                    .glassButtonLabel()
            }
            .buttonStyle(.glass)
        }
        .foregroundStyle(.white)
    }
    
    // MARK: - Private Functions
    
    private func updateShareImage() {
        let card = ComparisonShareCard(
            beforePhoto: viewModel.beforePhoto,
            afterPhoto: viewModel.afterPhoto,
            beforeMeasurement: viewModel.beforeMeasurement,
            afterMeasurement: viewModel.afterMeasurement
        )
        let renderer = ImageRenderer(content: card)
        renderer.scale = displayScale
        guard let uiImage = renderer.uiImage else { return }
        shareImage = Image(uiImage: uiImage)
    }
}

// MARK: - PhotoPickerSheet

private struct PhotoPickerSheet: View {
    
    let photos: [ProgressPhoto]
    let excluding: ProgressPhoto
    let title: String
    let onSelect: (ProgressPhoto) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.sm), count: 3),
                    spacing: DS.Spacing.sm
                ) {
                    ForEach(photos) { photo in
                        let isExcluded = photo.id == excluding.id
                        PhotoThumbnailView(photo: photo)
                            .opacity(isExcluded ? 0.3 : 1)
                            .onTapGesture {
                                guard !isExcluded else { return }
                                onSelect(photo)
                                dismiss()
                            }
                            .accessibilityAddTraits(isExcluded ? [] : .isButton)
                    }
                }
                .padding(DS.Spacing.lg)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
            }
        }
    }
}

// MARK: - ComparisonShareCard

private struct ComparisonShareCard: View {
    
    let beforePhoto: ProgressPhoto
    let afterPhoto: ProgressPhoto
    let beforeMeasurement: BodyMeasurement?
    let afterMeasurement: BodyMeasurement?
    
    var body: some View {
        HStack(spacing: 0) {
            side(photo: beforePhoto, measurement: beforeMeasurement, label: String(localized: "Before"))
            side(photo: afterPhoto, measurement: afterMeasurement, label: String(localized: "After"))
        }
        .frame(width: 800, height: 600)
        .background(.black)
    }
    
    @ViewBuilder
    private func side(photo: ProgressPhoto, measurement: BodyMeasurement?, label: String) -> some View {
        ZStack(alignment: .bottom) {
            if let uiImage = UIImage(data: photo.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.backgroundSecondary
            }
            
            VStack(spacing: 2) {
                Text(verbatim: "\(label) · \(photo.angle.localizedName) · \(photo.date.formatted(date: .abbreviated, time: .omitted))")
                if let measurement {
                    Text(verbatim: "\(measurement.weightKg.formatted(.number.precision(.fractionLength(1)))) kg")
                }
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(DS.Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(.black.opacity(0.55))
        }
        .frame(width: 400, height: 600)
        .clipped()
    }
}

#Preview("Both sides matched", traits: .previewContainer(.empty)) {
    @Previewable @Environment(AppContainer.self) var container
    @Previewable @Environment(\.modelContext) var modelContext
    let before = ProgressPhoto(date: .now.addingTimeInterval(-60 * 60 * 24 * 30), angle: .front, imageData: Data())
    let after = ProgressPhoto(date: .now, angle: .front, imageData: Data())
    PhotoComparisonView(
        photos: [before, after],
        measurementRepository: container.bodyMeasurementRepository
    )
    .task {
        modelContext.insert(BodyMeasurement(date: before.date, weightKg: 82, heightCm: 178, biologicalSex: .male))
        modelContext.insert(BodyMeasurement(date: after.date, weightKg: 79, heightCm: 178, biologicalSex: .male))
    }
}

#Preview("One side missing match", traits: .previewContainer(.empty)) {
    @Previewable @Environment(AppContainer.self) var container
    @Previewable @Environment(\.modelContext) var modelContext
    let before = ProgressPhoto(date: .now.addingTimeInterval(-60 * 60 * 24 * 90), angle: .front, imageData: Data())
    let after = ProgressPhoto(date: .now, angle: .front, imageData: Data())
    PhotoComparisonView(
        photos: [before, after],
        measurementRepository: container.bodyMeasurementRepository
    )
    .task {
        modelContext.insert(BodyMeasurement(date: after.date, weightKg: 79, heightCm: 178, biologicalSex: .male))
    }
}
