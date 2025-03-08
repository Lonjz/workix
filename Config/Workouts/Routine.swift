//
//  Routine.swift
//  workix
//
//  Created by Leon Yang on 2025-03-08.
//

import Foundation

struct Routine: Codable {
    let id: UUID
    var name: String
    var exercises: [RoutineExercise]
}

struct RoutineExercise: Codable {
    let exerciseid: UUID
    var sets: Int
    var reps: Int
}
