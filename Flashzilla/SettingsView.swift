//
//  Copyright © 2019 Peter Barclay. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var keepWrongCards: Bool
    
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Toggle(isOn: $keepWrongCards) {
                        Text("Keep wrongly answered cards")
                    }.padding()
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(leading: Button("Close", action: dismiss))
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(keepWrongCards: .constant(false))
        }
    }
}
