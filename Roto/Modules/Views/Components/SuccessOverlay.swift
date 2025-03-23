//
//  SuccessOverlay.swift
//  Roto
//
//  Created by Michael Bridges on 2/18/25.
//
import SwiftUI
struct SuccessOverlay: View {
    @Environment(\.appStyle) private var style
    
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Text("Continue")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(style.accentColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(Color.black.opacity(0.001)) // Very transparent background to capture taps but be invisible
        .edgesIgnoringSafeArea(.all)
    }
}
