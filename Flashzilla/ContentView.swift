//
//  Copyright © 2019 Peter Barclay. All rights reserved.
//

import CoreHaptics
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 300, height: 300)
                .onTapGesture {
                    print("Rectangle tapped!")
                }

            Circle()
                .fill(Color.red)
                .frame(width: 300, height: 300)
                .contentShape(Rectangle()) // shape used for tappable area
                .onTapGesture {
                    print("Circle tapped!")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
