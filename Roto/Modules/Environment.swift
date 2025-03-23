//
//  AppStyleEnvironment.swift
//  Roto
//
//  Created by Michael Bridges on 2/17/25.
//

import SwiftUI

// Environment key for app-wide style configuration
struct AppStyleConfigKey: EnvironmentKey {
    static let defaultValue = AppStyleConfig.default
}


struct NavigationViewModelKey: EnvironmentKey {
    static let defaultValue = NavigationViewModel()
}

extension EnvironmentValues {
    var appStyle: AppStyleConfig {
        get { self[AppStyleConfigKey.self] }
        set { self[AppStyleConfigKey.self] = newValue }
    }
    
    var navigationVM: NavigationViewModel {
        get { self[NavigationViewModelKey.self] }
        set { self[NavigationViewModelKey.self] = newValue }
    }
    
}

