//
//  E.swift
//  workix
//
//  Created by Leon Yang on 2025-03-08.
//

import SwiftUI

struct ExerciseLogView: View {
    @StateObject private var viewModel = ExerciseView()
    
    var body: some View {
        NavigationView {
            List(viewModel.exercises) { exercise in
                VStack(alignment: .leading) {
                    Text(exercise.name)
                        .font(.headline)
                    Text("Main Muscle Group: \(exercise.mainMuscleGroup)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Sub Muscles: \(exercise.subMuscleGroup.joined(separator: ", "))")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("Exercises")
        }
    }
}
