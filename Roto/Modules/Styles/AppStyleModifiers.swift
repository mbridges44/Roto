import SwiftUI

// MARK: - View Modifiers

struct AppInputFieldModifier: ViewModifier {
    let config: AppStyleConfig
    
    func body(content: Content) -> some View {
        content
            .font(config.bodyFont)
            .padding(config.inputFieldPadding)
            .background(config.textFieldBackground)
            .cornerRadius(config.inputCornerRadius)
            .shadow(
                color: config.shadowColor,
                radius: config.inputShadowRadius,
                x: 0,
                y: config.inputShadowY
            )
    }
}

struct AppButtonModifier: ViewModifier {
    let config: AppStyleConfig
    
    func body(content: Content) -> some View {
        content
            .font(config.bodyFont.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(config.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(config.buttonCornerRadius)
    }
}

struct AppSectionHeaderModifier: ViewModifier {
    let config: AppStyleConfig
    
    func body(content: Content) -> some View {
        content
            .font(config.headerFont)
            .foregroundColor(Color(config.primaryColor))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
    }
}

// MARK: - View Extensions

extension View {
    func appInputField(_ config: AppStyleConfig = .default) -> some View {
        self.modifier(AppInputFieldModifier(config: config))
    }
    
    func appButton(_ config: AppStyleConfig = .default) -> some View {
        self.modifier(AppButtonModifier(config: config))
    }
    
    func appSectionHeader(_ config: AppStyleConfig = .default) -> some View {
        self.modifier(AppSectionHeaderModifier(config: config))
    }
}

// MARK: - Reusable Components

struct AppStyledTextField: View {
    let placeholder: String
    @Binding var text: String
    let onSubmit: () -> Void
    @Environment(\.appStyle) private var style
    
var body: some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: $text)
                .appInputField(style)
            
            Button(action: onSubmit) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(style.accentColor)
                    .imageScale(.large)
            }
            .padding(.trailing, 4)
        }
    }
}

struct AppStyledButton: View {
    let title: String
    let action: () -> Void
    @Environment(\.appStyle) private var style
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .appButton(style)
        }
    }
}

struct AppSectionHeader: View {
    let title: String
    @Environment(\.appStyle) private var style
    
    var body: some View {
        Text(title)
            .appSectionHeader(style)
    }
}
