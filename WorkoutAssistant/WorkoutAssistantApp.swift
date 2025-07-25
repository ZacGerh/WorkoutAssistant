// ===== START FILE: WorkoutAssistantApp.swift =====
import SwiftUI
import SwiftData

@main
struct WorkoutAssistantApp: App {
    @State private var showCorruptionAlert = false

    var sharedModelContainer: ModelContainer = {
        do {
            let container = try ModelContainer(for: Workout.self, WorkoutSet.self)
            return container
        } catch {
            // If the container cannot be created, assume corrupted data and reset
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .corruptionDetected, object: nil)
            }
            print("SwiftData store might be corrupted: \(error)")
            let storeURL = URL.documentsDirectory.appending(path: "default.store")
            if FileManager.default.fileExists(atPath: storeURL.path) {
                do {
                    try FileManager.default.removeItem(at: storeURL)
                    print("Deleted corrupted SwiftData store at: \(storeURL.path)")
                } catch {
                    print("Failed to delete corrupted store: \(error)")
                }
            }
            // Try creating a fresh container
            do {
                return try ModelContainer(for: Workout.self, WorkoutSet.self)
            } catch {
                fatalError("Could not create fresh ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .onReceive(NotificationCenter.default.publisher(for: .corruptionDetected)) { _ in
                    showCorruptionAlert = true
                }
                .alert("Data Reset", isPresented: $showCorruptionAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Your saved data was corrupted and has been reset.")
                }
        }
    }
}

extension Notification.Name {
    static let corruptionDetected = Notification.Name("SwiftDataCorruptionDetected")
}
// ===== END FILE: WorkoutAssistantApp.swift =====
