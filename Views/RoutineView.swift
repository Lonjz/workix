//
//  RoutineView.swift
//  workix
//
//  Created by Leon Yang on 2025-03-08.
//

import SwiftUI

struct RoutineView: View {
    @State private var routines: [Routine] = []
    @State private var showingCreateRoutine = false
    private let api = RoutineAPI()

    var body: some View {
        NavigationStack {
            List {
                if routines.isEmpty {
                    Text("No routines found. Tap '+' to add one.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(routines, id: \.id) { routine in
                        NavigationLink(destination: EditRoutineView(routine: routine, updateRoutine: updateRoutine)) {
                            VStack(alignment: .leading) {
                                Text(routine.name)
                                    .font(.headline)
                                Text("\(routine.exercises.count) exercises")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deleteRoutine)
                }
            }
            .navigationTitle("Routines")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingCreateRoutine = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateRoutine) {
                CreateRoutineView(addRoutine: addRoutine)
            }
            .onAppear {
                loadRoutines()
            }
        }
    }

    private func loadRoutines() {
        api.fetchRoutines { fetchedRoutines in
            DispatchQueue.main.async {
                if let fetchedRoutines = fetchedRoutines {
                    self.routines = fetchedRoutines
                }
            }
        }
    }

    func addRoutine(_ routine: Routine) {
        api.createRoutine(routine) { success in
            if success {
                loadRoutines()
            }
        }
    }

    func updateRoutine(_ updatedRoutine: Routine) {
        api.updateRoutine(updatedRoutine) { success in
            if success {
                loadRoutines()
            }
        }
    }

    func deleteRoutine(at offsets: IndexSet) {
        let routineIdsToDelete = offsets.map { routines[$0].id }

        for routineId in routineIdsToDelete {
            api.deleteRoutine(routineId) { success in
                if success {
                    DispatchQueue.main.async {
                        self.routines.removeAll { $0.id == routineId }
                    }
                }
            }
        }
    }
}
