//
//  ListItemView.swift
//  Roto
//
//  Created by Michael Bridges on 2/18/25.
//
import SwiftUI

struct ListItemView: View {
    let text: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 16))
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .imageScale(.medium)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
