import Foundation

protocol BodyMeasurementRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [BodyMeasurement]
    func fetchLatest() async throws -> BodyMeasurement?

    func save(_ measurement: BodyMeasurement) async throws
    func delete(_ measurement: BodyMeasurement) async throws
}
