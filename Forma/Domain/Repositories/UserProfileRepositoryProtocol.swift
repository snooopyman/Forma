import Foundation

protocol UserProfileRepositoryProtocol: Sendable {
    func fetch() async throws -> UserProfile?
    func save(_ profile: UserProfile) async throws
}
