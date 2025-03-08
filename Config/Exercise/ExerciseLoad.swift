//
//  ExerciseLoad.swift
//  workix
//
//  Created by Leon Yang on 2025-03-08.
//

import Foundation

class ExerciseLoad {
    static func loadExercises() -> [Exercise] {
        print("Bundle Path: \(Bundle.main.bundlePath)")

        if let resourceURL = Bundle.main.resourceURL {
            print("Resource URL: \(resourceURL.path)")
        }

        if let path = Bundle.main.path(forResource: "Exercises", ofType: "json") {
            print("Found exercises.json at: \(path)")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                return try JSONDecoder().decode([Exercise].self, from: data)
            } catch {
                print("ERROR: Failed to decode JSON - \(error)")
            }
        } else {
            print("ERROR: Could not find exercises.json")
        }
        return []
    }
}
