//
//  ConsentDataItem.swift
//  ClickioSDK_Integration_Example_iOS_SwiftUI
//

import SwiftUI

// MARK: - ConsentDataItem
struct ConsentDataItem: Identifiable {
    // MARK: Properties
    let id = UUID()
    let title: String
    let value: String
    
    // MARK: Initializer
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
}
