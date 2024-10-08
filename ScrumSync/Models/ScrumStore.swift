//
//  ScrumStore.swift
//  ScrumSync
//
//  Created by John Carlos on 30/09/24.
//

import SwiftUI


@MainActor
// The class must be marked as @MainActor before it is safe to update the published scrums property from the asynchronous load() method.
class ScrumStore: ObservableObject {
    @Published var scrums: [DailyScrum] = []


    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("scrums.data") // return the URL of a file named scrums.data
    }


    func load() async throws {
        let task = Task<[DailyScrum], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let dailyScrums = try JSONDecoder().decode([DailyScrum].self, from: data)
            return dailyScrums
        }
        let scrums = try await task.value
        self.scrums = scrums
    }


    func save(scrums: [DailyScrum]) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(scrums)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}
