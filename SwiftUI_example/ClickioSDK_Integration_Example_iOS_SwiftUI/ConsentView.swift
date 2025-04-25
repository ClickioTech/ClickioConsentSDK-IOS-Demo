//
//  ConsentView.swift
//  ClickioSDK_Integration_Example_iOS_SwiftUI
//

import SwiftUI
import ClickioConsentSDKManager

// MARK: - ConsentView
struct ConsentView: View {
    // MARK: Properties
    @State private var consentData: [ConsentDataItem] = ConsentView.defaultConsentData()
    @State private var isInitialized = false
    
    // MARK: Set up SDK Consifuration
    private let config = ClickioConsentSDK.Config(siteId: "241131", appLanguage: "en")
    
    // MARK: Body
    var body: some View {
        ZStack {
            VStack {
                buttonsSection
                consentList
            }
            .disabled(!isInitialized)
            
            if !isInitialized {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.8)))
            }
        }
        .onAppear(perform: initializeSDK)
    }
    
    // MARK: Subviews
    private var buttonsSection: some View {
        VStack(spacing: 10) {
            Button("Open Consent Dialog") {
                // MARK: If an app has it's own ATT Permission manager it just sends false in showATTFirst & attNeeded parameters and calls it's own ATT method and then calls openDialog method.
                
                // MARK: Important: make sure that user has given permission in the ATT dialog and only then perfrom openDialog method call! Showing CMP regardles given ATT Permission is not recommended by Apple. Moreover, openDialog API call can be blocked by Apple until user makes their choice.
                
                
                // Example scenario if you have custom ATT Manager:
                /*
                 DefaultAppATTManager.shared.requestPermission { isGrantedAccess in
                 print(isGrantedAccess)
                 ClickioConsentSDK.shared.openDialog(
                     mode: .resurface,
                     showATTFirst: false,
                     attNeeded: false
                 )
                 }
                 */
                
                ClickioConsentSDK.shared.openDialog(
                    mode: .resurface,
                    showATTFirst: true,
                    attNeeded: true
                )
            }
            .buttonStyle(PrimaryButtonStyle(disabled: !isInitialized))
            
            Button("Refresh Consent Data") {
                refreshConsentData()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
    }
    
    private var consentList: some View {
        List(consentData) { item in
            ConsentRow(title: item.title, value: item.value)
        }
    }
    
    // MARK: - Methods
    private func initializeSDK() {
        // MARK: Set up event logger
        ClickioConsentSDK.shared.setLogsMode(.verbose)
        
        // MARK: Register callbacks before initialization
        ClickioConsentSDK.shared.onReady {
            isInitialized = true
        }
        
        ClickioConsentSDK.shared.onConsentUpdated {
            refreshConsentData()
        }
        
        // MARK: Initialize SDK
        Task {
            await ClickioConsentSDK.shared.initialize(configuration: config)
        }
    }
    
    // Default "Unknown" values for list initialization
    private static func defaultConsentData() -> [ConsentDataItem] {
        return [
            ConsentDataItem("checkConsentScope", "Unknown"),
            ConsentDataItem("checkConsentState", "Unknown"),
            ConsentDataItem("checkConsentForPurpose(1)", "Unknown"),
            ConsentDataItem("checkConsentForVendor(9)", "Unknown"),
            ConsentDataItem(" ", " "),
            ConsentDataItem("getTCString", "Unknown"),
            ConsentDataItem("getACString", "Unknown"),
            ConsentDataItem("getGPPString", "Unknown"),
            ConsentDataItem("getConsentedTCFVendors", "Unknown"),
            ConsentDataItem("getConsentedTCFLiVendors", "Unknown"),
            ConsentDataItem("getConsentedTCFPurposes", "Unknown"),
            ConsentDataItem("getConsentedTCFLiPurposes", "Unknown"),
            ConsentDataItem("getConsentedGoogleVendors", "Unknown"),
            ConsentDataItem("getConsentedOtherVendors", "Unknown"),
            ConsentDataItem("getConsentedOtherLiVendors", "Unknown"),
            ConsentDataItem("getConsentedNonTcfPurposes", "Unknown"),
            ConsentDataItem("getGoogleConsentMode", "Unknown")
        ]
    }
    
    // Update consent data values for list
    private func refreshConsentData() {
        let consentSDK = ClickioConsentSDK.shared
        let exportData = ExportData()
        
        let consentScope = consentSDK.checkConsentScope() ?? "Unknown"
        let consentState = consentSDK.checkConsentState()?.rawValue ?? "Unknown"
        let consentForPurpose = consentSDK.checkConsentForPurpose(purposeId: 1)?.description ?? "Unknown"
        let consentForVendor = consentSDK.checkConsentForVendor(vendorId: 9)?.description ?? "Unknown"
        
        let tcString = exportData.getTCString() ?? "Unknown"
        let acString = exportData.getACString() ?? "Unknown"
        let gppString = exportData.getGPPString() ?? "Unknown"
        let consentedTCFVendors = exportData.getConsentedTCFVendors()?.description ?? "Unknown"
        let consentedTCFLiVendors = exportData.getConsentedTCFLiVendors()?.description ?? "Unknown"
        let consentedTCFPurposes = exportData.getConsentedTCFPurposes()?.description ?? "Unknown"
        let consentedTCFLiPurposes = exportData.getConsentedTCFLiPurposes()?.description ?? "Unknown"
        let consentedGoogleVendors = exportData.getConsentedGoogleVendors()?.description ?? "Unknown"
        let consentedOtherVendors = exportData.getConsentedOtherVendors()?.description ?? "Unknown"
        let consentedOtherLiVendors = exportData.getConsentedOtherLiVendors()?.description ?? "Unknown"
        let consentedNonTcfPurposes = exportData.getConsentedNonTcfPurposes()?.description ?? "Unknown"
        
        let googleConsentMode = exportData.getGoogleConsentMode()
        let googleConsentString = "Analytics Storage: \(googleConsentMode?.analyticsStorageGranted ?? false), Ad Storage: \(googleConsentMode?.adStorageGranted ?? false), Ad User Data: \(googleConsentMode?.adUserDataGranted ?? false), Ad Personalization: \(googleConsentMode?.adPersonalizationGranted ?? false)"
        
        consentData = [
            ConsentDataItem("checkConsentScope", consentScope),
            ConsentDataItem("checkConsentState", consentState),
            ConsentDataItem("checkConsentForPurpose(1)", consentForPurpose),
            ConsentDataItem("checkConsentForVendor(9)", consentForVendor),
            ConsentDataItem(" ", " "),
            ConsentDataItem("getTCString", tcString),
            ConsentDataItem("getACString", acString),
            ConsentDataItem("getGPPString", gppString),
            ConsentDataItem("getConsentedTCFVendors", consentedTCFVendors),
            ConsentDataItem("getConsentedTCFLiVendors", consentedTCFLiVendors),
            ConsentDataItem("getConsentedTCFPurposes", consentedTCFPurposes),
            ConsentDataItem("getConsentedTCFLiPurposes", consentedTCFLiPurposes),
            ConsentDataItem("getConsentedGoogleVendors", consentedGoogleVendors),
            ConsentDataItem("getConsentedOtherVendors", consentedOtherVendors),
            ConsentDataItem("getConsentedOtherLiVendors", consentedOtherLiVendors),
            ConsentDataItem("getConsentedNonTcfPurposes", consentedNonTcfPurposes),
            ConsentDataItem("getGoogleConsentMode", googleConsentString)
        ]
    }
}

// MARK: - Data Models
struct ConsentDataItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    
    init(_ title: String, _ value: String) {
        self.title = title
        self.value = value
    }
}

// MARK: - Custom Views
struct ConsentRow: View {
    let title: String
    let value: String
    
    var body: some View {
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

struct PrimaryButtonStyle: ButtonStyle {
    let disabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(disabled ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Preview
//struct ConsentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConsentView()
//    }
//}
