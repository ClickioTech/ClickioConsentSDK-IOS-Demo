//
//  ConsentRow.swift
//  ClickioSDK_Integration_Example_iOS_SwiftUI
//

import SwiftUI

// MARK: - ConsentRow
public struct ConsentRow: View {
    // MARK: Properties
    let title: String
    let value: String
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
