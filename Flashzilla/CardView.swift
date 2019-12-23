//
//  Copyright © 2019 Peter Barclay. All rights reserved.
//

import SwiftUI

struct CardView: View {
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @State var isShowingAnswer = false
    @State var offset = CGSize.zero
    
    let card: Card
    var removal: ((_ isCorrect: Bool) -> Void)? = nil
    private let feedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(
                differentiateWithoutColor
                    ? Color(UIColor.systemBackground)
                    : Color(UIColor.systemBackground)
                        .opacity(1 - Double(abs(offset.width / 50)))

            )
            .background(
                differentiateWithoutColor
                    ? nil
                    : RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(offset.width > 0 ? Color.green : Color.red)
            )
            .shadow(color: .primary, radius: 10)
            
            VStack {
                if accessibilityEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)

                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                }
            }

        }
        .frame(width: 450, height: 250)
        .onTapGesture {
            self.isShowingAnswer.toggle()
        }
        .animation(.spring()) // TODO: Challenge 3 - determine how to prevent background color change while animating
        .padding(20)
        .multilineTextAlignment(.center)
        .rotationEffect(.degrees(Double(offset.width / 5)))
        .offset(x: offset.width * 5, y: 0)
        .opacity(2 - Double(abs(offset.width / 50)))
        .accessibility(addTraits: .isButton)
        .gesture(
            DragGesture()
                .onChanged { offset in
                    self.offset = offset.translation
                    self.feedback.prepare()
                }
                .onEnded { _ in
                    if abs(self.offset.width) > 100 {
                        let isCorrect: Bool
                        if self.offset.width > 0 {
                            isCorrect = true
                            self.feedback.notificationOccurred(.success)
                        } else {
                            isCorrect = false
                            self.feedback.notificationOccurred(.error)
                        }
                        
                        self.removal?(isCorrect)
                    }
                    self.offset = .zero
                }
        )
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardView(card: Card.example)
            CardView(card: Card.example)
                .environment(\.colorScheme, .dark)
        }
    }
}
