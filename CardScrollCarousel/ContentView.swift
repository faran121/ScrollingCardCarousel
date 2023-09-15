//
//  ContentView.swift
//  CardScrollCarousel
//
//  Created by Maliks on 14/09/2023.
//

import SwiftUI

struct ContentView: View {
    let cards = [Card(), Card(), Card(), Card(), Card(), Card()]
    
    @State private var screenWidth: CGFloat = 0
    @State private var cardHeight: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var activeCardIndex = 0
    
    let widthScale = 0.75
    let cardAspectRatio = 1.75
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                ForEach(cards.indices, id: \.self) { index in
                    VStack {
                    }
                    .frame(width: screenWidth * widthScale, height: cardHeight)
                    .background(cards[index].colors[index % cards.count].gradient)
                    .overlay(Color.white.opacity(1 - cardScale(for: index, proportion: 0.4)))
                    .cornerRadius(20)
                    .offset(x: cardOffset(for: index))
                    .scaleEffect(x: cardScale(for: index), y: cardScale(for: index))
                    .zIndex(-Double(index))
                    .gesture(DragGesture().onChanged { value in
                        self.dragOffset = value.translation.width
                    }.onEnded { value in
                        let threshold = screenWidth * 0.2
                        
                        withAnimation {
                            if value.translation.width < -threshold {
                                activeCardIndex = min(activeCardIndex + 1, cards.count - 1)
                            }
                            else if value.translation.width > threshold {
                                activeCardIndex = max(activeCardIndex - 1, 0)
                            }
                        }
                        
                        withAnimation {
                            dragOffset = 0
                        }
                    })
                }
            }
            .onAppear {
                screenWidth = reader.size.width
                cardHeight = screenWidth * widthScale * cardAspectRatio
            }
            .offset(x: 16, y: 30)
        }
    }
    
    func cardOffset(for index: Int) -> CGFloat {
        let adjustedIndex = index - activeCardIndex
        let cardSpacing: CGFloat = 60 / cardScale(for: index)
        let initialOffset = cardSpacing * CGFloat(adjustedIndex)
        let progress = min(abs(dragOffset)/(screenWidth/2), 1)
        let maxCardMovement = cardSpacing
        
        if adjustedIndex < 0 {
            if dragOffset > 0 && index == activeCardIndex - 1 {
                let distanceToMove = (initialOffset + screenWidth) * progress
                return -screenWidth + distanceToMove
            }
            else {
                return -screenWidth
            }
        }
        else if index > activeCardIndex {
            let distanceToMove = progress * maxCardMovement
            return initialOffset - (dragOffset < 0 ? distanceToMove : -distanceToMove)
        }
        else {
            if dragOffset < 0 {
                return dragOffset
            }
            else {
                let distanceToMove = maxCardMovement * progress
                return initialOffset - (dragOffset < 0 ? distanceToMove : -distanceToMove)
            }
        }
    }
    
    func cardScale(for index: Int, proportion: CGFloat = 0.2) -> CGFloat {
        let adjustedIndex = index - activeCardIndex
        
        if index >= activeCardIndex {
            let progress = min(abs(dragOffset)/(screenWidth/2), 1)
            return 1 - proportion * CGFloat(adjustedIndex) + (dragOffset < 0 ? proportion * progress : -proportion * progress)
        }
        return 1
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Card {
    let id = UUID()
    let colors: [Color] = [.red, .blue, .pink, .brown, .cyan, .green, .indigo, .mint, .orange]
}
