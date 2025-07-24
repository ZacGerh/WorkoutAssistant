// Workout.swift
import Foundation

struct Workout: Identifiable, Codable {
    let id: UUID
    var name: String
    var weight: Double
    var incrementWeight: Double
    var initialReps: Int
    var sets: [SetButton.SetState]

    init(id: UUID = UUID(), name: String, weight: Double, incrementWeight: Double, initialReps: Int, sets: [SetButton.SetState]) {
        self.id = id
        self.name = name
        self.weight = weight
        self.incrementWeight = incrementWeight
        self.initialReps = initialReps
        self.sets = sets
    }
}

extension SetButton.SetState: Codable {
    enum CodingKeys: String, CodingKey {
        case type, reps
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .notStarted(let reps):
            try container.encode("notStarted", forKey: .type)
            try container.encode(reps, forKey: .reps)
        case .success(let reps):
            try container.encode("success", forKey: .type)
            try container.encode(reps, forKey: .reps)
        case .failure(let reps):
            try container.encode("failure", forKey: .type)
            try container.encode(reps, forKey: .reps)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let reps = try container.decode(Int.self, forKey: .reps)
        switch type {
        case "notStarted": self = .notStarted(reps)
        case "success": self = .success(reps)
        case "failure": self = .failure(reps)
        default: self = .notStarted(reps)
        }
    }
}
