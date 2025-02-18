import SwiftUI

struct AppStyleConfig {
    // Colors
    let backgroundColor: Color
    let primaryColor: Color
    let accentColor: Color
    let textFieldBackground: Color
    let shadowColor: Color
    
    // Typography
    let titleFont: Font
    let bodyFont: Font
    let headerFont: Font
    
    // Spacing
    let defaultPadding: CGFloat
    let sectionSpacing: CGFloat
    let inputFieldPadding: CGFloat
    
    // Sizing
    let buttonCornerRadius: CGFloat
    let inputCornerRadius: CGFloat
    
    // Shadows
    let inputShadowRadius: CGFloat
    let inputShadowY: CGFloat
    
    static let `default` = AppStyleConfig(
        backgroundColor: Color("BrandBackground"),
        primaryColor: Color("BrandPrimary"),
        accentColor: Color("AccentColor"),
        textFieldBackground: .white,
        shadowColor: Color.black.opacity(0.05),
        
        titleFont: .system(size: 28, weight: .bold),
        bodyFont: .system(size: 16),
        headerFont: .system(size: 16, weight: .medium),
        
        defaultPadding: 24,
        sectionSpacing: 24,
        inputFieldPadding: 12,
        
        buttonCornerRadius: 8,
        inputCornerRadius: 8,
        
        inputShadowRadius: 2,
        inputShadowY: 1
    )
}
