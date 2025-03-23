import SwiftUI

// This view modifier adds a tap gesture to the content to dismiss the keyboard
struct DismissKeyboardOnTapModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
            
            // Overlay with a clear color that captures taps
            // Since we're using overlay rather than background, we place it in front
            // of the view but then make it non-interactive so it won't block other taps
            Color.clear
                .contentShape(Rectangle()) // Makes the entire area tappable
                .onTapGesture {
                    // Dismiss the keyboard by ending editing
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                  to: nil, from: nil, for: nil)
                }
                .allowsHitTesting(true) // Allow hit testing on this layer
        }
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        self.modifier(DismissKeyboardOnTapModifier())
    }
}

// For iOS 16 and later, we can use the newer FocusState API
// to dismiss keyboards more elegantly
struct KeyboardDismissModifier: ViewModifier {
    @FocusState private var isInputActive: Bool

    func body(content: Content) -> some View {
        content
            .focused($isInputActive)
            .onTapGesture {
                isInputActive = false
            }
    }
}

// Alternative tap gesture approach that works in most scenarios
struct TapToDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                      to: nil, from: nil, for: nil)
                    }
            )
    }
}
