import SwiftUI

struct NewView: View {
    @State private var records: [DictRecord] = []
    @State private var currentIndex = 0
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State private var removedIndices: Set<Int> = []
    @State private var lastSwipeDirection: SwipeDirection = .none
    @State private var swipeDirections: [SwipeDirection] = []
    @State private var swipedNumbers: [Int] = [0, 0, 0]
    
    let cardWidth: CGFloat = 300
    let cardSpacing: CGFloat = -10
    let peekAmount: CGFloat = 30
    
    enum SwipeDirection {
        case left, right, up, down, none
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    ForEach(records.indices, id: \.self) { index in
                        if !removedIndices.contains(index) {
                            Flashcard(record: records[index], scale: scale(for: index, in: geometry))
                                .frame(width: cardWidth)
                                .offset(x: xOffset(for: index, in: geometry),
                                        y: index == currentIndex ? offsetY : 0)
                        }
                    }
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if abs(gesture.translation.width) > abs(gesture.translation.height) {
                                // Horizontal swipe
                                self.offsetX = gesture.translation.width
                                self.offsetY = 0
                            } else {
                                // Vertical swipe
                                self.offsetX = 0
                                self.offsetY = gesture.translation.height
                            }
                        }
                        .onEnded { gesture in
                            handleSwipe(gesture: gesture, cardWidth: geometry.size.width, cardHeight: geometry.size.height)
                        }
                )
                .animation(.spring(duration: 0.3), value: currentIndex)
            }
            .onAppear {
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                    self.records = DictRecord.sampleData
                } else {
                    self.records = CSVLoader.loadCSV(from: "dict")
                }
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
        }
    }
    
    private func xOffset(for index: Int, in geometry: GeometryProxy) -> CGFloat {
        let adjustedCardWidth = cardWidth + cardSpacing
        let baseOffset = CGFloat(index - currentIndex) * adjustedCardWidth
        let rightEdgeOfMainCard = (geometry.size.width + cardWidth) / 2 - peekAmount
        let leftEdgeOfMainCard = rightEdgeOfMainCard - cardWidth - peekAmount / 2
        return leftEdgeOfMainCard + baseOffset + offsetX
    }
    
    private func scale(for index: Int, in geometry: GeometryProxy) -> CGFloat {
        let currentCardCenterX = geometry.size.width / 2
        let cardPositionX = xOffset(for: index, in: geometry) + cardWidth / 2
        let distanceFromCenterX = cardPositionX - currentCardCenterX

        let currentCardCenterY = geometry.size.height / 2
        let cardPositionY = index == currentIndex ? offsetY + currentCardCenterY : currentCardCenterY
        let distanceFromCenterY = cardPositionY - currentCardCenterY

        let distance = sqrt(pow(distanceFromCenterX, 2) + pow(distanceFromCenterY, 2))

        if distance < 60 {
            // Card is close to the center
            return 1.0
        } else if distanceFromCenterX < -60 {
            // Card is to the left of center (swiped left)
            let leftThreshold = -cardWidth
            return max(0, (cardPositionX - leftThreshold) / (cardWidth * 1.5))
        } else {
            // Card is to the right of center or off-center vertically
            let maxDistance = max(geometry.size.width, geometry.size.height) / 2
            let scale = pow(0.85, distance / (maxDistance / 2))
            return max(scale, 0.8)
        }
    }
    
    private func handleSwipe(gesture: DragGesture.Value, cardWidth: CGFloat, cardHeight: CGFloat) {
        let horizontalSwipeThreshold: CGFloat = cardWidth / 5
        let verticalSwipeThreshold: CGFloat = cardHeight / 5
        
        if abs(gesture.translation.height) > verticalSwipeThreshold {
            // Vertical swipe (up or down)
            removedIndices.insert(currentIndex)
            lastSwipeDirection = gesture.translation.height > 0 ? .down : .up
            if lastSwipeDirection == .down {swipedNumbers[2] += 1}
            else {swipedNumbers[1] += 1}
            moveToNextCard()
        } else if gesture.translation.width > horizontalSwipeThreshold && currentIndex > 0 {
            // Right swipe
            switch swipeDirections[currentIndex - 1] {
            case .left:
                swipedNumbers[0] -= 1
            case .up:
                swipedNumbers[1] -= 1
            case .down:
                swipedNumbers[2] -= 1
            default:
                print("unregistered swipe")
            }
            withAnimation(.spring(duration: 0.3, bounce: 0.3)) {
                let previousIndex = currentIndex - 1
//                    print(removedIndices, previousIndex)
                if removedIndices.contains(previousIndex) {
                    // Custom animation for bringing back a removed card
                    offsetY = 1000
                    removedIndices.remove(previousIndex)
                    withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                        currentIndex -= 1
                        offsetY = 0
                    }
                } else {
                    withAnimation(.spring(duration: 0.3, bounce: 0.3)) {
                        currentIndex -= 1
                    }
                }
                swipeDirections.removeLast()
                lastSwipeDirection = .right
            }
        } else if gesture.translation.width < -horizontalSwipeThreshold && currentIndex < records.count - 1 {
            // Left swipe
//            removedIndices.insert(currentIndex)
            swipedNumbers[0] += 1
            lastSwipeDirection = .left
            withAnimation(.spring(duration: 0.3, bounce: 0.3)) {
                moveToNextCard()
            }
        } else {
            // No significant swipe, reset to center
            lastSwipeDirection = .none
        }
        
        if lastSwipeDirection != .right && lastSwipeDirection != .none {
            print("APPENDING \(lastSwipeDirection)")
            swipeDirections.append(lastSwipeDirection)
        }
        
        print("\(swipedNumbers)")
        
        withAnimation(.spring(duration: 0.3, bounce: 0.3)) {
            offsetX = 0
            offsetY = 0
        }
    }
    
    private func moveToNextCard() {
        if currentIndex < records.count - 1 {
            currentIndex += 1
        }
    }
}

#Preview {
    NewView()
}
