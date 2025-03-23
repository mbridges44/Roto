import SwiftUI
//
//  GloballyStyledView.swift
//  Roto
//
//  Created by Michael Bridges on 2/17/25.
//
struct GlobalStyledView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color("BrandBackground")
                .ignoresSafeArea()
            content
                .foregroundColor(Color("BrandPrimary"))
                .accentColor(Color("AccentColor"))
        }
    }
}

