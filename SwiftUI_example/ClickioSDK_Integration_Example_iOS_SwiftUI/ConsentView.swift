//
//  ConsentView.swift
//  ClickioSDK_Integration_Example_iOS_SwiftUI
//

import SwiftUI
import ClickioConsentSDKManager
import GoogleMobileAds

// MARK: - ConsentView
struct ConsentView: View {
    // MARK: Properties
    @State private var consentData: [ConsentDataItem] = ConsentView.defaultConsentData()
    @State private var isInitialized = false
    @State private var shouldLoadAds = false
    @State private var showClearDataAlert = false
    @AppStorage("openDialogOnStart") private var openDialogOnStart = false
    @AppStorage("enableVerboseLogging") private var enableVerboseLogging = true
    
    // MARK: Set up SDK Configuration
    private let config = ClickioConsentSDK.Config(siteId: "240920", appLanguage: "en") // Replace "241131" with your own Site ID
    
    // MARK: Body
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                buttonsSection
                consentList
                BannerAdView(adUnitID: "/21775744923/example/fixed-size-banner", shouldLoadAds: shouldLoadAds)
                    .frame(height: 100)
            }
            .padding()
            .disabled(!isInitialized)
            
            if !isInitialized {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            }
        }
        .onAppear(perform: initializeSDK)
    }
    
    // MARK: Subviews
    private var buttonsSection: some View {
        VStack(spacing: 10) {
            Toggle("Open dialog when application starts", isOn: $openDialogOnStart)
                .padding(.horizontal)
            
            Toggle("Clickio SDK verbose logging", isOn: $enableVerboseLogging)
                .padding(.horizontal)
                .onChange(of: enableVerboseLogging) { newValue in
                    ClickioConsentSDK.shared.setLogsMode(newValue ? .verbose : .disabled)
                }
            
            Button("Open Consent Dialog") {
                ClickioConsentSDK.shared.openDialog(mode: .default, attNeeded: true)
            }
            .buttonStyle(PrimaryButtonStyle(disabled: !isInitialized))
            
            Button("Resurface") {
                ClickioConsentSDK.shared.openDialog(mode: .resurface, attNeeded: true)
            }
            .buttonStyle(PrimaryButtonStyle(disabled: !isInitialized))
            
            Button("Refresh Consent Data") {
                refreshConsentData()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button(action: {
                showClearDataAlert = true
            }) {
                Text("Clear Data")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .alert("Clear Data", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearUserDefaults()
                }
            } message: {
                Text("This will clear all stored consent data. Are you sure?")
            }
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
        ClickioConsentSDK.shared.setLogsMode(enableVerboseLogging ? .verbose : .disabled)
        
        // MARK: Register callbacks before initialization
        ClickioConsentSDK.shared.onReady {
            isInitialized = true
            print("ConsentView: SDK is ready")
            
            // Handle consent state using the shared function
            handleConsentStateChange()
            
            // Open dialog if enabled
            if openDialogOnStart {
                print("ConsentView: Opening dialog on start")
                ClickioConsentSDK.shared.openDialog(mode: .default, attNeeded: true)
            }
        }
        
        ClickioConsentSDK.shared.onConsentUpdated {
            print("ConsentView: Consent updated")
            // Handle consent state using the shared function
            handleConsentStateChange()
        }
        
        // MARK: Initialize SDK
        print("ConsentView: Starting SDK initialization")
        Task {
            await ClickioConsentSDK.shared.initialize(configuration: config)
        }
    }
    
    // Extracted function to handle consent state changes
    private func handleConsentStateChange() {
        // Check consent state
        if let consentState = ClickioConsentSDK.shared.checkConsentState() {
            print("ConsentView: Current consent state = \(consentState)")
            if consentState == .notApplicable || consentState == .gdprDecisionObtained || consentState == .us {
                print("ConsentView: Consent state allows ads, initializing Google Mobile Ads if needed")
                // Initialize Google Mobile Ads if not already initialized
                if !shouldLoadAds {
                    MobileAds.shared.start(completionHandler: nil)
                    shouldLoadAds = true
                }
            } else {
                print("ConsentView: Consent state does not allow ads, stopping ads")
                // If consent is not in allowed states, stop loading ads
                shouldLoadAds = false
            }
        } else {
            print("ConsentView: Unable to get consent state")
            shouldLoadAds = false
        }
        
        // Refresh consent data
        refreshConsentData()
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
    
    private func clearUserDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            // Save the openDialogOnStart and enableVerboseLogging values before clearing
            let savedOpenDialogOnStart = openDialogOnStart
            let savedEnableVerboseLogging = enableVerboseLogging
            
            // Clear all UserDefaults
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
            
            // Restore the saved values
            openDialogOnStart = savedOpenDialogOnStart
            enableVerboseLogging = savedEnableVerboseLogging
            
            print("UserDefaults storage cleared for bundle: \(bundleID)")
            // Refresh consent data after clearing
            refreshConsentData()
        }
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
