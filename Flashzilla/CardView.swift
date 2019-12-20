//
//  CardView.swift
//  Flashzilla
//
//  Created by Peter on 20/12/2019.
//  Copyright © 2019 Peter Barclay. All rights reserved.
//

import SwiftUI

struct CardView: View {
    @State var isShowingAnswer = false

    let card: Card

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color.white)
                .shadow(radius: 10)

            VStack {
                Text(card.prompt)
                    .font(.largeTitle)

                if isShowingAnswer {
                    Text(card.answer)
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                self.isShowingAnswer.toggle()
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example)
    }
}
