//
//  StartButton.swift
//  SmartOBD2
//
//  Created by kemo konteh on 8/26/23.
//

import SwiftUI

struct StartButton: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isToggled = false

    var startColor: Color { Color.sstartColor(for: colorScheme) }
    var endColor: Color { Color.sendColor(for: colorScheme) }
    var shadowColor: Color { colorScheme == .dark ? .sdarkStart : .slightStart }
    
    var body: some View {
        VStack {
            Text("hello world ")
        }
//        VStack {
//            Toggle(isOn: $isToggled) {
//                Text("Start")
//                    .foregroundColor(.white)
//            }
//            .toggleStyle(ButtonToggleStyle2())
//            
//        }
//        .frame(width: 20, height: 20)
    }
}

struct ButtonToggleStyle2: ToggleStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        
        Button(action: {
            configuration.isOn.toggle()
            print("pressed")
            let impactLight = UIImpactFeedbackGenerator(style: .light)
            impactLight.impactOccurred()
        }) {
            configuration.label
                .frame(width: 90, height: 90)
                .contentShape(RoundedRectangle(cornerRadius: 45))
        }
        .background(
            ButtonBackgroun(isHighlighted: configuration.isOn, shape: RoundedRectangle(cornerRadius: 45))
        )
        .animation(Animation.easeOut.speed(2.5), value: configuration.isOn)
        
    }
}

struct ButtonBackgroun<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    @Environment(\.colorScheme) var colorScheme
    var startColor: Color { Color.startColor(for: colorScheme) }
    var endColor: Color { Color.endColor(for: colorScheme) }
    var shadowColor: Color { colorScheme == .dark ? .darkStart : .lightStart }

    var body: some View {
        ZStack {
            shape
                .fill(LinearGradient(endColor, startColor))
                .shadow(color: shadowColor, radius: 10, x: -10, y: -10)
                .shadow(color: shadowColor, radius: 10, x: 10, y: 10)
                .blur(radius: isHighlighted ? 4 : 3)
        }
    }
}
extension Color {
    static let sdarkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    static let sdarkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)
    static let slightStart = Color(red: 240 / 255, green: 240 / 255, blue: 246 / 255)
    static let slightEnd = Color(red: 120 / 255, green: 120 / 255, blue: 123 / 255)

    static func sstartColor(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? .sdarkStart : .slightStart
    }

    static func sendColor(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? .sdarkEnd : .slightEnd
    }
}

#Preview {
    StartButton()
}
