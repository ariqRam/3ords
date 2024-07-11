//
//  FlashcardsView.swift
//  ThreeWords
//
//  Created by Ariq Ramdhany on 09/07/24.
//

import SwiftUI

struct FlashcardsView: View {
    @State private var records: [DictRecord] = []
    
    @State private var offsets: [UUID: CGSize] = [:]
    @State private var isSwipedUp: Bool = false
    
    func color(for offset: CGSize) -> Color {
        let maxOffset = 200.0
        if offset.height < 0 {
            let normalizedOffset = min(max(Double(abs(offset.height)) / maxOffset, 0), 1)
            let brightness = (1.0 - (normalizedOffset * 0.5)) * 0.96
            let saturation = (1.0 - (normalizedOffset * 0.5)) * 0.73
            let hue = (1.0 - (normalizedOffset * 0.5)) * (347/360)
            return Color(hue:hue, saturation: saturation, brightness: brightness)
        }
        let normalizedOffset = min(max(Double(abs(offset.height)) / maxOffset, 0), 1)
        let brightness = (1.0 - (normalizedOffset * 0.5)) * 0.96
            return Color(hue: 347/360, saturation: 0.73, brightness: brightness)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
                HStack{
                    ForEach(records.indices, id: \.self) { id in
                        ZStack {
                            RoundedRectangle(cornerSize: CGSize(width: 20, height: 10))
                                .frame(height: 350)
                                .foregroundColor(color(for: offsets[records[id].id] ?? .zero))
                                .shadow(radius: 5)
                                .animation(.linear, value: offsets[records[id].id]?.height ?? 0)
                                
                            VStack{
                                Text(records[id].word)
                                    .containerRelativeFrame(.horizontal)
                                    .font(.title)
                                    .fontWeight(.heavy)
                                Text(records[id].reading)
                                    .font(.system(size: 15))
                                Text(records[id].meaning)
                                    .font(.system(size:20))
                            }
                            .foregroundColor(.white)
                        }
                        .frame(height: 800)
                        .background(Color.clear)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1.0 : 0.5)
                                .scaleEffect(phase.isIdentity ? 1.0 : 0.9)
                        }
                        .offset(y: offsets[records[id].id]?.height ?? 0)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                            // Update the offset as the user drags
                                            self.offsets[records[id].id] = gesture.translation
                                        }
                                .onEnded { gesture in
                                    withAnimation {
                                        // Check if the user has swiped up past the threshold
                                        if abs(gesture.translation.height) > 200 {
                                            // Remove the record at the current index
                                            self.records.remove(at: id)
                                            self.offsets[records[id].id] = nil
                                        } else {
                                            // Reset the card’s position if the swipe-up threshold is not met
                                            self.offsets[records[id].id] = .zero
                                        }
                                    }
                                }
                        )
                    }
//                    .onDelete(
//                        perform:
//                    )
                }
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
        .background(Color.clear)
        .scrollTargetLayout(isEnabled: true)
        .scrollTargetBehavior(.viewAligned)
        .safeAreaPadding(.horizontal, 40)
        .contentMargins(8, for: .scrollContent)
        
    }
}

#Preview {
    FlashcardsView()
}
