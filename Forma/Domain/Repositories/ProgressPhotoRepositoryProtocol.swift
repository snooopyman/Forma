//
//  ProgressPhotoRepositoryProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 5/4/26.
//

import Foundation

protocol ProgressPhotoRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [ProgressPhoto]
    func save(_ photo: ProgressPhoto) async throws
    func delete(_ photo: ProgressPhoto) async throws
}
