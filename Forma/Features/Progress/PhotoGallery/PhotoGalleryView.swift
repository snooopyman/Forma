//
//  PhotoGalleryView.swift
//  Forma
//
//  Created by Armando Cáceres on 5/4/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct PhotoGalleryView: View {

    // MARK: - Private Properties

    @State private var viewModel: PhotoGalleryViewModel
    @State private var showAddPhoto = false
    @State private var selectedPhoto: ProgressPhoto?

    // MARK: - Environment

    @Environment(AppContainer.self) private var container

    // MARK: - Initializers

    init(repository: ProgressPhotoRepositoryProtocol) {
        _viewModel = State(initialValue: PhotoGalleryViewModel(repository: repository))
    }

    // MARK: - Body

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.photos.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.photos.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .navigationTitle(String(localized: "Photo gallery"))
        .background(.backgroundPrimary)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddPhoto = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(String(localized: "Add photo"))
            }
        }
        .sheet(isPresented: $showAddPhoto) {
            AddProgressPhotoSheet(
                repository: container.progressPhotoRepository,
                existingPhotos: viewModel.photos
            ) {
                Task { await viewModel.load() }
            }
        }
        .fullScreenCover(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo)
        }
        .alert(
            String(localized: "Error"),
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            if let msg = viewModel.errorMessage { Text(msg) }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DS.Spacing.lg) {
                ForEach(viewModel.groupedPhotos, id: \.header) { group in
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text(group.header)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.textSecondary)

                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.sm), count: 3),
                            spacing: DS.Spacing.sm
                        ) {
                            ForEach(group.photos) { photo in
                                PhotoThumbnailView(photo: photo)
                                    .onTapGesture { selectedPhoto = photo }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            Task { await viewModel.delete(photo) }
                                        } label: {
                                            Label(String(localized: "Delete"), systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .padding(DS.Spacing.lg)
        }
    }

    private var emptyView: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "photo.stack")
                .font(.system(size: 56))
                .foregroundStyle(.textTertiary)
                .accessibilityHidden(true)
            VStack(spacing: DS.Spacing.sm) {
                Text(String(localized: "No photos yet"))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                Text(String(localized: "Add your first progress photo to track visual changes"))
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            Button(String(localized: "Add photo")) {
                showAddPhoto = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(DS.Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - PhotoThumbnailView

private struct PhotoThumbnailView: View {

    let photo: ProgressPhoto

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let uiImage = UIImage(data: photo.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.backgroundSecondary
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.textTertiary)
                        }
                }
            }
            .clipped()
            .overlay(alignment: .bottomLeading) {
                Text(photo.angle.localizedName)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, DS.Spacing.xs)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.inner))
                    .padding(DS.Spacing.xs)
            }
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.chip))
    }
}

// MARK: - PhotoDetailView

private struct PhotoDetailView: View {

    let photo: ProgressPhoto

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.black.ignoresSafeArea()

                if let uiImage = UIImage(data: photo.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                if !photo.notes.isEmpty {
                    Text(photo.notes)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(DS.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.black.opacity(0.6))
                }
            }
            .navigationTitle(photo.angle.localizedName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Done")) { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

// MARK: - AddProgressPhotoSheet

private struct AddProgressPhotoSheet: View {

    // MARK: - Private Properties

    let repository: ProgressPhotoRepositoryProtocol
    let existingPhotos: [ProgressPhoto]
    let onSaved: @MainActor () -> Void

    // MARK: - States

    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var angle: PhotoAngle = .front
    @State private var date: Date = .now
    @State private var notes = ""
    @State private var isSaving = false
    @State private var showReplaceAlert = false

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Computed Properties

    private var duplicatePhoto: ProgressPhoto? {
        let cal = Calendar.current
        return existingPhotos.first { photo in
            photo.angle == angle &&
            cal.isDate(photo.date, equalTo: date, toGranularity: .month)
        }
    }

    // MARK: - Body

    var body: some View {
        let currentImageData = imageData
        let bgSecondary = Color.backgroundSecondary
        let accentColor = Color.accent
        let mdSpacing = DS.Spacing.md
        let buttonRadius = DS.Radius.button
        return NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack(spacing: mdSpacing) {
                            if let data = currentImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: buttonRadius))
                            } else {
                                RoundedRectangle(cornerRadius: buttonRadius)
                                    .fill(bgSecondary)
                                    .frame(width: 60, height: 60)
                                    .overlay {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.title2)
                                            .foregroundStyle(accentColor)
                                    }
                            }
                            Text(currentImageData == nil ? String(localized: "Select photo") : String(localized: "Change photo"))
                                .foregroundStyle(accentColor)
                        }
                    }
                }

                Section {
                    Picker(String(localized: "Angle"), selection: $angle) {
                        ForEach(PhotoAngle.allCases, id: \.self) { a in
                            Text(a.localizedName).tag(a)
                        }
                    }
                    DatePicker(
                        String(localized: "Date"),
                        selection: $date,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                } footer: {
                    if duplicatePhoto != nil {
                        Text(String(localized: "You already have a photo for this angle this month. Saving will replace it."))
                            .foregroundStyle(.warning)
                    }
                }

                Section(String(localized: "Notes")) {
                    TextField(String(localized: "Optional notes"), text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle(String(localized: "New photo"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        if duplicatePhoto != nil {
                            showReplaceAlert = true
                        } else {
                            Task { await save() }
                        }
                    }
                    .disabled(imageData == nil || isSaving)
                }
            }
            .alert(String(localized: "Replace photo?"), isPresented: $showReplaceAlert) {
                Button(String(localized: "Replace"), role: .destructive) {
                    Task { await save(replacing: duplicatePhoto) }
                }
                Button(String(localized: "Cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "You already have a \(angle.localizedName.lowercased()) photo for this month. Do you want to replace it?"))
            }
        }
        .onChange(of: selectedItem) { @MainActor _, newItem in
            Task {
                imageData = try? await newItem?.loadTransferable(type: Data.self)
            }
        }
    }

    // MARK: - Private Functions

    private func save(replacing existing: ProgressPhoto? = nil) async {
        guard let data = imageData else { return }
        isSaving = true
        if let existing {
            try? await repository.delete(existing)
        }
        let photo = ProgressPhoto(date: date, angle: angle, imageData: data, notes: notes)
        try? await repository.save(photo)
        onSaved()
        dismiss()
    }
}

#Preview(traits: .previewContainer()) {
    @Previewable @Environment(AppContainer.self) var container
    NavigationStack {
        PhotoGalleryView(repository: container.progressPhotoRepository)
    }
}
