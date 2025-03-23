//
//  KeyboardObserver.swift
//  Roto
//
//  Created by Michael Bridges on 3/23/25.
//


import SwiftUI
import Combine

// MARK: - Keyboard Observer

// Class that tracks keyboard appearance/disappearance
class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    @Published var isKeyboardVisible = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                guard let userInfo = notification.userInfo,
                      let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                else { return nil }
                return keyboardFrame.height
            }
            .sink { [weak self] height in
                withAnimation {
                    self?.keyboardHeight = height
                    self?.isKeyboardVisible = true
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                withAnimation {
                    self?.keyboardHeight = 0
                    self?.isKeyboardVisible = false
                }
            }
            .store(in: &cancellables)
    }
}
