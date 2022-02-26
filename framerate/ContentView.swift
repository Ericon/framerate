//
//  ContentView.swift
//  framerate
//
//  Created by 刘鹏 on 2022/2/3.
//

import SwiftUI

class ToggleWithCADisplayLink : NSObject, ObservableObject {
    @Published var showBlack: Bool = false
    @Published var actualFramesPerSecond: Double = 0
    @Published var countDownSecondString: String = "5"
    
    var minimum: Float = 8
    var maximum: Float = 15
    var preferred: Float = 10
    var countDownSecond: Float = 5

    private var displaylink: CADisplayLink!
    private var progress: Double = 0
    private var previousTargetTimestamp: Double = 0
    func createDisplayLink() {
        if nil == displaylink {
            displaylink = CADisplayLink(target: self, selector: #selector(step))
            displaylink.preferredFrameRateRange = CAFrameRateRange(minimum:minimum, maximum:maximum, preferred:preferred)
            displaylink.add(to: .current, forMode: RunLoop.Mode.default)
        }
    }
    func disableDisplayLink() {
        displaylink.invalidate()
        displaylink = nil
        progress = 0
        previousTargetTimestamp = 0
        countDownSecond = 5
        showBlack = false
    }

    @objc func step(link: CADisplayLink) {
        if previousTargetTimestamp == 0 {
            progress = 0
        } else {
            progress += link.targetTimestamp - previousTargetTimestamp
        }
        previousTargetTimestamp = link.targetTimestamp
        actualFramesPerSecond = 1 / (displaylink.targetTimestamp - displaylink.timestamp)
        print("target time stamp: \(link.targetTimestamp)")
        print("actual frame rate: \(actualFramesPerSecond)")
        if countDownSecond > 0 {
            countDownSecond = 5 - Float(progress)
            countDownSecondString = "\(round(10 * countDownSecond) / 10.0)"
        } else {
            countDownSecondString = ""
            if progress > 1 {
                showBlack.toggle()
                progress = 0
            }
        }
    }
}

struct SecondView: View {
    @State var color: Color = .red
    @State var minimum: Float = 8
    @State var maximum: Float = 15
    @State var preferred: Float = 10
    
    @ObservedObject var animation = ToggleWithCADisplayLink()
    
    var body: some View {
        ZStack {
            VStack {
                Text(animation.countDownSecondString)
                    .foregroundColor(.yellow)
                Text("Actual Frame Rate: \(animation.actualFramesPerSecond)")
                    .foregroundColor(.yellow)
            }.zIndex(10)
            Rectangle()
                .foregroundColor(color)
                .zIndex(animation.showBlack ? 1 : 0)
            Rectangle()
                .foregroundColor(.black)
                .zIndex(animation.showBlack ? 0 : 1)
        }.frame(width: 400, height: 960)
            .onAppear {
                animation.minimum = minimum
                animation.maximum = maximum
                animation.preferred = preferred
                animation.createDisplayLink()
            }
            .onDisappear {
                animation.disableDisplayLink()
            }
    }
}

struct ContentView: View {
    @State private var minimum: String = "8"
    @State private var maximum: String = "15"
    @State private var preferred: String = "10"
    var body: some View {
        NavigationView {
            VStack {
                Text("minimum: default 8")
                TextField("minimum: default 8", text: $minimum)
                    .frame(width: 200, height: 30, alignment: .center)
                    .textFieldStyle(.roundedBorder)
                Text("maximum: default 15")
                TextField("maximum: default 15", text: $maximum)
                    .frame(width: 200, height: 30, alignment: .center)
                    .textFieldStyle(.roundedBorder)
                Text("preferred: default 10")
                TextField("preferred: default 10", text: $preferred)
                    .frame(width: 200, height: 30, alignment: .center)
                    .textFieldStyle(.roundedBorder)
                NavigationLink(destination: SecondView(color: .red, minimum: Float(minimum) ?? 8, maximum: Float(maximum) ?? 15, preferred: Float(preferred) ?? 10, animation: ToggleWithCADisplayLink())) {
                    Text("黑红1s交替")
                }
                .navigationTitle("Navigation")
                NavigationLink(destination: SecondView(color: .green, minimum: Float(minimum) ?? 8, maximum: Float(maximum) ?? 15, preferred: Float(preferred) ?? 10, animation: ToggleWithCADisplayLink())) {
                    Text("黑绿1s交替")
                }
                .navigationTitle("Navigation")
                NavigationLink(destination: SecondView(color: .blue, minimum: Float(minimum) ?? 8, maximum: Float(maximum) ?? 15, preferred: Float(preferred) ?? 10, animation: ToggleWithCADisplayLink())) {
                    Text("黑蓝1s交替")
                }
                .navigationTitle("Navigation")
                NavigationLink(destination: SecondView(color: .white, minimum: Float(minimum) ?? 8, maximum: Float(maximum) ?? 15, preferred: Float(preferred) ?? 10, animation: ToggleWithCADisplayLink())) {
                    Text("黑白1s交替")
                }
                .navigationTitle("Navigation")
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
