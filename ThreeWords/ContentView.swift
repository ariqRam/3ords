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
    var body: some View {
        FlashcardsView()
    }
}

#Preview {
    ContentView()
}
