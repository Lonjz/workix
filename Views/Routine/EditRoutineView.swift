//
//  EditRoutineView.swift
//  workix
//
//  Created by Leon Yang on 2025-03-08.
//

import SwiftUI

struct EditRoutineView: View {
    @State var routine: Routine
    var updateRoutine: (Routine) -> Void
    @Environment(\.dismiss) var dismiss

    let allExercises: [Exercise] = ExerciseLoad.loadExercises()

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Routine Name", text: $routine.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List {
                    ForEach($routine.exercises, id: \.exerciseid) { $exercise in
                        HStack {
       
                            Text(exerciseName(for: exercise.exerciseid))
                                .font(.headline)
                            
                            Spacer()

                            VStack {
                                Stepper("Sets: \(exercise.sets)", value: $exercise.sets, in: 1...10)
                                Stepper("Reps: \(exercise.reps)", value: $exercise.reps, in: 1...20)
                            }
                        }
                    }
                }

                Button("Save Changes") {
                    updateRoutine(routine)
                    dismiss()
                }
                .buttonStyle(.bordered)
                .padding()
            }
            .navigationTitle("Edit Routine")
        }
    }

    func exerciseName(for id: UUID) -> String {
        return allExercises.first(where: { $0.id == id })?.name ?? "Unknown Exercise"
    }
}
