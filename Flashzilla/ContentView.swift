//
//  Copyright © 2019 Peter Barclay. All rights reserved.
//

import CoreHaptics
import SwiftUI

struct ContentView: View {
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @State private var cards = [Card]()
    @State private var timeRemaining = 100
    @State private var showingTimedOut = false
    @State private var isActive = true
    @State private var showingEditScreen = false
    @State private var showingSettings = false
    @State private var showingSheet = false
    @State private var keepWrongCards = false
    @State private var engine: CHHapticEngine?

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let showingSheet = Binding(
            get: {
                return self.showingEditScreen || self.showingSettings
            },
            set: {
                self.showingSettings = $0
                self.showingEditScreen = $0
            }
        )
        
        return ZStack {
            Image(decorative: "background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Time: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.black)
                            .opacity(0.75)
                    )
                
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: self.cards[index]) { isCorrect in
                           withAnimation {
                                self.removeCard(at: index, isCorrect: isCorrect)
                           }
                        }
                        .stacked(at: index, in: self.cards.count)
                        .allowsHitTesting(index == self.cards.count - 1)
                        .accessibility(hidden: index < self.cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                if cards.isEmpty {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
            }
            
            VStack {
                HStack {
                    Spacer()

                    Button(action: {
                        self.showingEditScreen = true
                    }) {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }

                    Spacer().frame(width: 20)

                    Button(action: {
                        self.showingSettings = true
                    }) {
                        Image(systemName: "gear")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }

                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            if differentiateWithoutColor || accessibilityEnabled {
                VStack {
                    Spacer()

                    HStack {
                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1, isCorrect: false)
                            }
                        }) {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as being incorrect."))
                        Spacer()

                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1, isCorrect: true)
                            }
                        }) {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Correct"))
                        .accessibility(hint: Text("Mark your answer as being correct."))
                    }
                }
            }
        }
        .onAppear(perform: resetCards)
        .sheet(isPresented: showingSheet, onDismiss: resetCards) {
            self.sheetView()
        }
        .popover(isPresented: self.$showingTimedOut) {
            VStack {
                Text("Time is up!")
                .font(.largeTitle)
                .padding()
            }
            .onAppear {
                DispatchQueue.global().async {
                    sleep(2)
                    DispatchQueue.main.async {
                        self.showingTimedOut = false
                        self.cards = []
                    }
                }
            }
        }
        .onReceive(timer) { time in
            guard self.isActive else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
            
            if self.timeRemaining == 1 && self.showingTimedOut == false {
                self.prepareHaptics()
            }
            
            if self.timeRemaining == 0 && self.showingTimedOut == false {
                self.isActive = false
                self.showingTimedOut = true
                self.timedOutHaptics()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if self.cards.isEmpty == false {
                self.isActive = true
            }
        }
    }
    
    func sheetView() -> some View {
        if self.showingEditScreen == true {
            return AnyView(EditCards())
        } else if self.showingSettings {
            return AnyView(SettingsView(keepWrongCards: self.$keepWrongCards))
        } else {
            return AnyView(Text("Something whent wrong!"))
        }
    }
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }

    func timedOutHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        for i in stride(from: 0, to: 1, by: 0.05) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i * 2)
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }

    func removeCard(at index: Int, isCorrect: Bool) {
        guard index >= 0 else { return }
        
        if !isCorrect && self.keepWrongCards {
            cards.move(fromOffsets: [index], toOffset: 0)
        } else {
            cards.remove(at: index)
        }

        if cards.isEmpty {
            isActive = false
        }
    }
        
    func resetCards() {
        timeRemaining = 100
        showingTimedOut = false
        showingSettings = false
        isActive = true
        loadData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
            .environment(\.colorScheme, .dark)
        }
    }
}
