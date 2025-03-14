//
//  RoutineAPI.swift
//  workix
//
//  Created by Leon Yang on 2025-03-08.
//

import Foundation

class RoutineAPI {
    private var supabaseURL: String
    private var apiKey: String
    
    init() {
        self.supabaseURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? ""
        self.apiKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_API_KEY") as? String ?? ""
        self.supabaseURL += "/rest/v1"
        
        print("DEBUG: SUPABASE_URL = \(supabaseURL.isEmpty ? "EMPTY" : supabaseURL)")
        print("DEBUG: SUPABASE_API_KEY = \(apiKey.isEmpty ? "EMPTY" : apiKey)")
    }

    func fetchRoutines(completion: @escaping ([Routine]?) -> Void) {
        let requestURL = "\(supabaseURL)/routines?select=id,name,exercises(sets,reps,exerciseid)"

        guard let url = URL(string: requestURL) else {
            print("ERROR: Invalid Supabase URL: \(requestURL)")
            return
        }

        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ ERROR: Failed to fetch routines - \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            do {
                let routines = try JSONDecoder().decode([Routine].self, from: data)
                DispatchQueue.main.async {
                    completion(routines)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }

    func createRoutine(_ routine: Routine, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(self.supabaseURL)/routines") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(self.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue(self.apiKey, forHTTPHeaderField: "apikey")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let routineData = ["id": routine.id.uuidString, "name": routine.name]
            request.httpBody = try JSONEncoder().encode(routineData)
        } catch {
            print("❌ ERROR: Failed to encode routine - \(error)")
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil {
                print("✅ Routine saved successfully!")
                self.saveRoutineExercises(routine.exercises, forRoutineId: routine.id, completion: completion)
            } else {
                print("❌ ERROR: Failed to create routine - \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
            }
        }.resume()
    }

      
    private func saveRoutineExercises(_ exercises: [RoutineExercise], forRoutineId routineId: UUID, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(self.supabaseURL)/exercises") else { return }
            
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(self.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue(self.apiKey, forHTTPHeaderField: "apikey")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")

        struct ExerciseEntry: Codable {
            let routine_id: String
            let exerciseid: String
            let sets: Int
            let reps: Int
        }

        let exercisesData = exercises.map { ExerciseEntry(routine_id: routineId.uuidString, exerciseid: $0.exerciseid.uuidString, sets: $0.sets, reps: $0.reps) }

        do {
            request.httpBody = try JSONEncoder().encode(exercisesData)
        } catch {
            print("❌ ERROR: Failed to encode exercises - \(error)")
            completion(false)
            return
        }
            
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    print("ℹ️ Response Code: \(httpResponse.statusCode)")
                }

                if error == nil {
                    print("✅ Routine exercises saved/updated successfully!")
                    completion(true)
                } else {
                    print("❌ ERROR: Failed to save routine exercises - \(error?.localizedDescription ?? "Unknown error")")
                    completion(false)
                }
            }
        }.resume()
    }

    func updateRoutine(_ routine: Routine, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(self.supabaseURL)/routines?id=eq.\(routine.id.uuidString)") else {
            print("❌ ERROR: Invalid URL for updating routine")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let routineData = ["name": routine.name]
            request.httpBody = try JSONEncoder().encode(routineData)
        } catch {
            print("❌ ERROR: Failed to encode routine update - \(error)")
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("ℹ️ Response Code: \(httpResponse.statusCode)")
            }
            
            if error == nil {
                print("✅ Routine name updated successfully!")
                
                self.saveRoutineExercises(routine.exercises, forRoutineId: routine.id, completion: completion)
            } else {
                print("❌ ERROR: Failed to update routine - \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
            }
        }.resume()
    }

    func deleteRoutine(_ routineId: UUID, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(self.supabaseURL)/routines?id=eq.\(routineId.uuidString)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(self.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { _, response, error in
            if error == nil {
                print("✅ Routine deleted successfully!")

                self.deleteRoutineExercises(forRoutineId: routineId, completion: completion)
            } else {
                print("❌ ERROR: Failed to delete routine - \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
            }
        }.resume()
    }

    private func deleteRoutineExercises(forRoutineId routineId: UUID, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(self.supabaseURL)/exercises?routine_id=eq.\(routineId.uuidString)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(self.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    print("✅ All exercises for routine deleted!")
                } else {
                    print("❌ ERROR: Failed to delete exercises - \(error?.localizedDescription ?? "Unknown error")")
                }
                completion(error == nil)
            }
        }.resume()
    }
}
