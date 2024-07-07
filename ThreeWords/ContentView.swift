//
//  ContentView.swift
//  ThreeWords
//
//  Created by Ariq Ramdhany on 17/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var records: [DictRecord] = []
    var body: some View {
        List(records) { record in
            VStack(alignment: .leading, content: {
                Text(record.reading)
                Text(record.meaning)
            })
        }
        .onAppear{
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                self.records = DictRecord.sampleData
            } else {
                print("loading CSV")
                print(CSVLoader.loadCSV(from: "dict"))
                self.records = CSVLoader.loadCSV(from: "dict")
                print("done loading", records)
            }
        }
    }
}

#Preview {
    ContentView()
}
