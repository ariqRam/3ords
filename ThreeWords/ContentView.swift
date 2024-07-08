//
//  ContentView.swift
//  ThreeWords
//
//  Created by Ariq Ramdhany on 17/06/24.
//

import SwiftUI

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

struct ContentView: View {
    @State private var records: [DictRecord] = []
    var body: some View {
        ScrollView(.horizontal) {
                HStack{
                    ForEach(records) { record in
                        ZStack {
                            RoundedRectangle(cornerSize: CGSize(width: 20, height: 10))
                                .foregroundColor(Color.primaryBg)
                            VStack{
                                Text(record.word)
                                    .containerRelativeFrame(.horizontal)
                                    .font(.title)
                                    .fontWeight(.heavy)
                                Text(record.reading)
                                    .font(.system(size: 15))
                                Text(record.meaning)
                                    .font(.system(size:20))
                            }
                            .foregroundColor(.white)
                        }
                        .frame(height: 350)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1.0 : 0.5)
                                .scaleEffect(phase.isIdentity ? 1.0 : 0.9)
                        }
                    }
                }
                
            
        }
        .scrollTargetLayout(isEnabled: true)
        .scrollTargetBehavior(.viewAligned)
        .safeAreaPadding(.horizontal, 40)
        .contentMargins(8, for: .scrollContent)
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
