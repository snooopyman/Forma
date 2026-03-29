import Foundation

protocol NutritionRepositoryProtocol: Sendable {
    func fetchAllPlans() async throws -> [NutritionPlan]
    func fetchActivePlan() async throws -> NutritionPlan?

    func savePlan(_ plan: NutritionPlan) async throws
    func deletePlan(_ plan: NutritionPlan) async throws

    func setActivePlan(_ plan: NutritionPlan) async throws

    func fetchLog(for date: Date) async throws -> DailyNutritionLog?
    func saveLog(_ log: DailyNutritionLog) async throws
}
