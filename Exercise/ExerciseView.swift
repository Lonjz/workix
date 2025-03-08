//
//  ExerciseView.swift
//  workix
//
//  Created by Leon Yang on 2025-03-08.
//

import SwiftUI

class ExerciseView: ObservableObject {
    @Published var exercises: [Exercise] = []

    init() {
            loadExercises()
        }

    func loadExercises() {
            exercises = ExerciseLoad.loadExercises()
        }
}
