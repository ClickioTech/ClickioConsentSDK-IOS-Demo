# Clickio Consent - iOS Sample Apps (UIKit & SwiftUI)

## Description

This sample app demonstrates how to integrate the  [Clickio Consent SDK](https://github.com/ClickioTech/ClickioConsentSDK-IOS)  into a basic iOS application both for UIKit & SwiftUI projects using Swift.

In particular, it shows how to:

-   Initialize the SDK with your site configuration
-   Show a consent dialog in default mode
-   Open the dialog again manually in resurface mode
-   Display all received consent data on button click or consent update
-   Show Google Ads if needed

## Setup & Run

Installation is simple:

1.  Clone or download the sample project.
2.  Open it in  **Xcode**.
3.  Build and run the app on a device or simulator.

No additional configuration is needed to get started — everything is included in the sample.

## SDK configuration and initialization for UIKit
```Swift
// Config SDK
private let config = ClickioConsentSDK.Config(siteId: "241131", appLanguage: "en") // Replace "241131" with your own Site ID

// Initialize SDK
override func viewDidLoad() {
  super.viewDidLoad()
  // show default “Unknown” values
  consentData = loadDefaultConsentData()
  
  // set-up event logger
  ClickioConsentSDK.shared.setLogsMode(.verbose)
  
  // Register callbacks before initialization 
  ClickioConsentSDK.shared.onReady { [weak self] in
    self?.openConsentButton.isEnabled = true
  }

  // refresh data on consent change
  ClickioConsentSDK.shared.onConsentUpdated { [weak self] in
    self?.getConsentData()
  }

  // async initialize
  Task {
    await ClickioConsentSDK.shared.initialize(configuration: config)
  }
}

// Call WebView Dialog
@objc private func openConsentWindow() {
ClickioConsentSDK.shared.openDialog(
mode: .resurface,
in: self, // use this parameter in UIKit projects to explicitly specify on which UIViewController the dialog will be presented. Don't use this parameter in SwiftUI projects.
attNeeded: true
  )
}
```
-   The  `241131`  in the line  `config = ClickioConsentSDK.Config("241131", "en")`  can be replaced with your own site identifier provided by Clickio.
-   The SDK opens the consent dialog when openConsentWindow() method is executed.

## SDK configuration and initialization for SwiftUI
```Swift
// Config SDK
private let config = ClickioConsentSDK.Config(siteId: "241131", appLanguage: "en") // Replace "241131" with your own Site ID

// Initialize SDK
.onAppear {
// set-up event logger
  ClickioConsentSDK.shared.setLogsMode(.verbose)
  
// Register callbacks before initialization 
  ClickioConsentSDK.shared.onReady {
    isInitialized = true
  }

// refresh data on consent change
  ClickioConsentSDK.shared.onConsentUpdated {
    refreshConsentData()
  }

// async initialize
  Task {
    await ClickioConsentSDK.shared.initialize(configuration: config)
  }
}

// Call WebView Dialog
Button("Open Consent Dialog") {
  ClickioConsentSDK.shared.openDialog(
    mode: .resurface,
    attNeeded: true
  )
}
.disabled(!isInitialized)
```
-   The  `241131`  in the line  `config = ClickioConsentSDK.Config("241131", "en")`  can be replaced with your own site identifier provided by Clickio.
-   The SDK opens the consent dialog when Open Consent Dialog button is tapped.


**Important Notes**
- Always wait for onReady callback before using SDK features
- Handle ATT permissions before showing CMP dialog
- Use ExportData class for consent value retrieval
- Implement onConsentUpdated for real-time updates
- Test with different regional settings (GDPR/US/Other)
