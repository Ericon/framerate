//
//  ContentView.swift
//  framerate
//
//  Created by 刘鹏 on 2022/2/3.
//

import SwiftUI

class ToggleWithCADisplayLink : NSObject, ObservableObject {
    @State var interval: Double = 1.0
    
    @Published var showBase: Bool = false
    @Published var actualFramesPerSecond: Double = 0
    @Published var countDownSecondString: String = "5"
    
    init(interval: Double) {
        self.interval = interval
    }
    
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
        showBase = false
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
            if progress > self.interval {
                showBase.toggle()
                progress = 0
            }
        }
    }
}

struct SecondView: View {
    @State var baseColor: Color = .black
    @State var color: Color = .red
    @State var minimum: Float = 8
    @State var maximum: Float = 15
    @State var preferred: Float = 10
    @ObservedObject var animation = ToggleWithCADisplayLink(interval: 1)
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                    .frame(height: 150)
                    .background(Color.yellow)
                Text(animation.countDownSecondString)
                    .font(.system(size: 28))
                    .foregroundColor(.yellow)
                Text("Actual Frame Rate: \(animation.actualFramesPerSecond)")
                    .font(.system(size: 28))
                    .foregroundColor(.yellow)
            }.zIndex(10)
            Rectangle()
                .foregroundColor(color)
                .zIndex(animation.showBase ? 1 : 0)
            Rectangle()
                .foregroundColor(baseColor)
                .zIndex(animation.showBase ? 0 : 1)
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
    @State private var color_1_r: String = "255"
    @State private var color_1_g: String = "255"
    @State private var color_1_b: String = "255"
    @State private var color_2_r: String = "0"
    @State private var color_2_g: String = "0"
    @State private var color_2_b: String = "0"
    
    @State private var minimum: String = "8"
    @State private var maximum: String = "15"
    @State private var preferred: String = "10"
    @State private var interval: String = "1"
    
    var body: some View {
        NavigationView {
            VStack {
                Group {
                    Group {
                        Text("Color_1 R G B")
                        HStack{
                            TextField("255", text: $color_1_r)
                                .frame(width: 60, height: 30, alignment: .center)
                                .textFieldStyle(.roundedBorder)
                            TextField("255", text: $color_1_g)
                                .frame(width: 60, height: 30, alignment: .center)
                                .textFieldStyle(.roundedBorder)
                            TextField("255", text: $color_1_b)
                                .frame(width: 60, height: 30, alignment: .center)
                                .textFieldStyle(.roundedBorder)
                        }
                        Text("Color_2 R G B")
                        HStack{
                            TextField("0", text: $color_2_r)
                                .frame(width: 60, height: 30, alignment: .center)
                                .textFieldStyle(.roundedBorder)
                            TextField("0", text: $color_2_g)
                                .frame(width: 60, height: 30, alignment: .center)
                                .textFieldStyle(.roundedBorder)
                            TextField("0", text: $color_2_b)
                                .frame(width: 60, height: 30, alignment: .center)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    Spacer()
                        .frame(height: 50)
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
                    Text("interval: default 1")
                    TextField("interval: default 1", text: $interval)
                        .frame(width: 200, height: 30, alignment: .center)
                        .textFieldStyle(.roundedBorder)
                }
                Spacer()
                    .frame(height: 50)
                NavigationLink(destination: SecondView(
                    baseColor: Color(red: (Double(color_1_r) ?? 0)/255.0, green: (Double(color_1_g) ?? 0)/255.0, blue: (Double(color_1_b) ?? 0)/255.0),
                    color: Color(red: (Double(color_2_r) ?? 0)/255.0, green: (Double(color_2_g) ?? 0)/255.0, blue: (Double(color_2_b) ?? 0)/255.0),
                    minimum: Float(minimum) ?? 8,
                    maximum: Float(maximum) ?? 15,
                    preferred: Float(preferred) ?? 10,
                    animation: ToggleWithCADisplayLink(interval: Double(interval) ?? 1.0))) {
                    Text("开始")
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
