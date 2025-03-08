//
//  Exercise.swift
//  workix
//
//  Created by Leon Yang on 2025-03-08.
//

import Foundation

struct Exercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var mainMuscleGroup: String
    var subMuscleGroup: [String]
}
