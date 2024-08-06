//
//  Flashcard.swift
//  ThreeWords
//
//  Created by Ariq Ramdhany on 19/07/24.
//

import SwiftUI

struct Flashcard: View {
    let record: DictRecord
    let scale: CGFloat
    let bgColor: Color = Color.primaryBg
    
    var body: some View {
        VStack {
            Text(record.word)
                .containerRelativeFrame(.horizontal)
                .font(.title)
                .fontWeight(.heavy)
            Text(record.reading)
                .font(.system(size: 15))
            Text(record.meaning)
                .font(.system(size:20))
        }
        .frame(width: 300, height: 350)
        .background(bgColor)
        .foregroundStyle(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .scaleEffect(scale)
    }
}

#Preview {
    Flashcard(record: DictRecord.sampleData[0], scale: 1)
}
