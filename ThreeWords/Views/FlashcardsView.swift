//
//  FlashcardsView.swift
//  ThreeWords
//
//  Created by Ariq Ramdhany on 09/07/24.
//

import SwiftUI

struct ScrolledItemKey: PreferenceKey {
    typealias Value = [Int]
    static var defaultValue: [Int] = []

    static func reduce(value: inout [Int], nextValue: () -> [Int]) {
        value.append(contentsOf: nextValue())
    }
}

struct FlashcardsView: View {
    @State private var records: [DictRecord] = []
    
    @State private var offsets: [UUID: CGSize] = [:]
    @State private var frameHeights: [UUID: CGFloat] = [:]
    @State private var swipedUUIDs: [UUID] = []
    @State private var isSwipedUp: Bool = false
    @State var activeId: Int? = 0
    
    @State private var swipedNumbers: [Int] = [0, 0, 0]
    
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
        ZStack { // stacking cards and swipedNumbers
            ScrollViewReader { scrollViewProxy in
                ScrollView(.horizontal) {
                        HStack{
                            ForEach(records.indices, id: \.self) { id in
                                ZStack {
                                    RoundedRectangle(cornerSize: CGSize(width: 20, height: 10))
                                        .frame(height: frameHeights[records[id].id] ?? 350)
                                        .frame(width: frameHeights[records[id].id] ?? 300)
                                        .animation(.linear, value: frameHeights[records[id].id] ?? 350)
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
                                .frame(height: 900)
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
                                                print("Scrollpos \(activeId ?? 0)")
                                                // Check if the user has swiped up past the threshold
                                                if abs(gesture.translation.height) > 200 {
                                                    // Remove the record at the current index
                                                    withAnimation {
                                                        scrollViewProxy.scrollTo(id+1)
                                                        if gesture.translation.height < 0 { // if swiped up
                                                            swipedNumbers[1] += 1
                                                            self.offsets[records[id].id] = CGSize(width: 0, height: -900)
                                                        } else { // if swiped down
                                                            swipedNumbers[2] += 1
                                                            self.offsets[records[id].id] = CGSize(width: 0, height: 900)
                                                        }
                                                        
                                                    }
                                                }
                                                else {
                                                    withAnimation {
                                                        // Reset the card’s position if the swipe-up threshold is not met
                                                        self.offsets[records[id].id] = .zero
                                                    }
                                                }
                                                
                                        }
                                )
                            }
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
                    swipedUUIDs.append(records[0].id)
                }
                .background(Color.clear)
                .onChange(of: activeId) { // swipe left
//                    print("\(activeId ?? -1)")
                    if let myId = activeId, myId > 0{
                        let id: Int = (activeId ?? 0) > 0 ? (activeId ?? 0) - 1 : 0
                        withAnimation{
//                            self.offsets[records[id].id] = CGSize(width: 900, height: 900)
                            self.frameHeights[records[id].id] = 0
                        }
                        swipedNumbers[0] += 1
                    }

                }
                .scrollTargetLayout(isEnabled: true)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $activeId)
                .safeAreaPadding(.horizontal, 40)
                .contentMargins(8, for: .scrollContent)
            }
            HStack{
                HStack {
                    Text("⬅️: \(swipedNumbers[0])")
                }
                HStack {
                    Text("⬆️: \(swipedNumbers[1])")
                }
                HStack {
                    Text("⬇️: \(swipedNumbers[2])")
                }
            }
                .offset(CGSize(width: 0, height: 250))
                .foregroundStyle(Color.black)
        }
        
    }
}

#Preview {
    FlashcardsView()
}
