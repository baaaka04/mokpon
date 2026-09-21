//
//  FlashingButtonStyle.swift
//  mokpon
//
//  Created by Artem Berezin on 21.09.2026.
//

import SwiftUI

struct FlashingButtonStyle<S: Shape>: ButtonStyle {
    let shape: S
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .background(.accent.opacity(configuration.isPressed ? 0.7 : 0))
            .clipShape(shape)
            .animation(.easeOut(duration: 0.5), value: configuration.isPressed)
    }
}
