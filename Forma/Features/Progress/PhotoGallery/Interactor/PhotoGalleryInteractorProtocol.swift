//
//  PhotoGalleryInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol PhotoGalleryInteractorProtocol: Sendable {
    func fetchPhotos() async throws -> [ProgressPhoto]
    func deletePhoto(_ photo: ProgressPhoto) async throws
}
