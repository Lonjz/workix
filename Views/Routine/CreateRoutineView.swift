//
//  CreateRoutineView.swift
//  workix
//
//  Created by Leon Yang on 2025-03-08.
//
import SwiftUI

struct CreateRoutineView: View {
    @State private var routineName: String = ""
    @State private var selectedExercises: [RoutineExercise] = []
    @State private var allExercises: [Exercise] = ExerciseLoad.loadExercises()
    var addRoutine: (Routine) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Routine Name", text: $routineName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List {
                    ForEach(allExercises, id: \.id) { exercise in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(exercise.name).font(.headline)
                                Text("Main Muscle: \(exercise.mainMuscleGroup)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if let index = selectedExercises.firstIndex(where: { $0.exerciseid == exercise.id }) {
                                Stepper("Sets: \(selectedExercises[index].sets)", value: $selectedExercises[index].sets, in: 1...10)
                                Stepper("Reps: \(selectedExercises[index].reps)", value: $selectedExercises[index].reps, in: 1...20)
                            } else {
                                Button("Add") {
                                    selectedExercises.append(RoutineExercise(exerciseid: exercise.id, sets: 3, reps: 10))
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }

                Button("Save Routine") {
                    let newRoutine = Routine(id: UUID(), name: routineName, exercises: selectedExercises)
                    addRoutine(newRoutine)
                    dismiss()
                }
                .buttonStyle(.bordered)
                .padding()
            }
            .navigationTitle("Create Routine")
        }
    }
}
