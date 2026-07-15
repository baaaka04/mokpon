//
//  GlassModifier.swift
//  mokpon
//
//  Created by Artem Berezin on 15/7/26.
//

import SwiftUI

struct GlassModifier<S: Shape>: ViewModifier {
    let shape: S
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: shape)
        } else {
            content.background(.ultraThinMaterial, in: shape)
        }
    }
}

extension View {
    func customGlassEffect<S: Shape>(in shape: S) -> some View {
        self.modifier(GlassModifier(shape: shape))
    }
}
