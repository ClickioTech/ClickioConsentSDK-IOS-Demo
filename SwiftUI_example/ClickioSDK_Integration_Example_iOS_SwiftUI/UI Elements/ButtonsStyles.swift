//
//  ButtonsStyles.swift
//  ClickioSDK_Integration_Example_iOS_SwiftUI
//

import SwiftUI

// MARK: - PrimaryButtonStyle
public struct PrimaryButtonStyle: ButtonStyle {
    // MARK: Properties
    let disabled: Bool
    
    // MARK: Methods
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(disabled ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - SecondaryButtonStyle
public struct SecondaryButtonStyle: ButtonStyle {
    // MARK: Methods
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
