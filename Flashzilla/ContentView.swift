//
//  Copyright © 2019 Peter Barclay. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            Text("Success")
                .onTapGesture(perform: simpleSuccess(.success))
                .padding()
            
            Text("Error")
                .onTapGesture(perform: simpleSuccess(.error))
                .padding()
            
            Text("Warning")
                .onTapGesture(perform: simpleSuccess(.warning))
                .padding()
        }
    }
    
    func simpleSuccess(_ feedback: UINotificationFeedbackGenerator.FeedbackType) -> () -> Void {
        return {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(feedback)
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
