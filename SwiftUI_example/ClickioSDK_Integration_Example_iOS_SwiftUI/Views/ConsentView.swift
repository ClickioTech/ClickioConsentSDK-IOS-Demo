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
    @State private var shouldShowAdsBanner = false
    @State private var showClearDataAlert = false
    
    @AppStorage("showDefaultCMPOnLaunch") private var showDefaultCMPOnLaunch = true
    @AppStorage("enableVerboseLogging") private var enableVerboseLogging = true
    
    // MARK: Set up SDK Configuration
    private let config = ClickioConsentSDK.Config(siteId: "241131", appLanguage: "en") // Replace "241131" with your own Site ID
    
    // MARK: Body
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                buttonsSection
                consentList
                // MARK: НЕ СРАБАТЫВАЕТ БРЕЙКПОИНТ ПРИ ПОВТОРНОМ ЗАПУСКЕ
                if shouldShowAdsBanner {
                    BannerAdView(adUnitID: "/21775744923/example/fixed-size-banner", shouldLoadAds: shouldShowAdsBanner)
                        .frame(height: 100)
                }
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
            Toggle("Enable verbose logging", isOn: $enableVerboseLogging)
                .padding(.horizontal)
                .onChange(of: enableVerboseLogging) { newValue in
                    ClickioConsentSDK.shared.setLogsMode(newValue ? .verbose : .disabled)
                }
            
            Button("Resurface mode") {
                ClickioConsentSDK.shared.openDialog(mode: .resurface, attNeeded: true)
            }
            .buttonStyle(PrimaryButtonStyle(disabled: !isInitialized))
            
            Button("Refresh Consent Data") {
                getConsentData()
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
        // set up event logger
        ClickioConsentSDK.shared.setLogsMode(enableVerboseLogging ? .verbose : .disabled)
        
        // register callbacks before initialization
        ClickioConsentSDK.shared.onReady {
            DispatchQueue.main.async {
                getConsentData()
                // check if possible to show ads
                self.checkIfCanShowAds()
                if !self.isInitialized {
                    self.isInitialized = true
                    if showDefaultCMPOnLaunch {
                        ClickioConsentSDK.shared.openDialog(mode: .default, attNeeded: true)
                    }
                }
            }
        }
        
        // register consent‐updated handler
        ClickioConsentSDK.shared.onConsentUpdated {
            handleConsentStateChange()
        }
        
        // kick off async init
        Task {
            await ClickioConsentSDK.shared.initialize(configuration: config)
        }
    }
    
    private func handleConsentStateChange() {
        checkIfCanShowAds()
        getConsentData()
    }
    
    private func checkIfCanShowAds() {
        guard let state = ClickioConsentSDK.shared.checkConsentState(),
              state != .gdprNoDecision else {
            if shouldShowAdsBanner {
                shouldShowAdsBanner = false
            }
            return
        }
        
        if !shouldShowAdsBanner {
            print("ConsentView: Consent state allows ads, showing Google Ads if needed")
            shouldShowAdsBanner = true
        }
    }
    
    // Default "Unknown" values for list initialization
    private static func defaultConsentData() -> [ConsentDataItem] {
        return [
            ConsentDataItem(title: "checkConsentScope", value: "Unknown"),
            ConsentDataItem(title: "checkConsentState", value: "Unknown"),
            ConsentDataItem(title: "checkConsentForPurpose(1)", value: "Unknown"),
            ConsentDataItem(title: "checkConsentForVendor(9)", value: "Unknown"),
            ConsentDataItem(title: " ", value: " "),
            ConsentDataItem(title: "getTCString", value: "Unknown"),
            ConsentDataItem(title: "getACString", value: "Unknown"),
            ConsentDataItem(title: "getGPPString", value: "Unknown"),
            ConsentDataItem(title: "getConsentedTCFVendors", value: "Unknown"),
            ConsentDataItem(title: "getConsentedTCFLiVendors", value: "Unknown"),
            ConsentDataItem(title: "getConsentedTCFPurposes", value: "Unknown"),
            ConsentDataItem(title: "getConsentedTCFLiPurposes", value: "Unknown"),
            ConsentDataItem(title: "getConsentedGoogleVendors", value: "Unknown"),
            ConsentDataItem(title: "getConsentedOtherVendors", value: "Unknown"),
            ConsentDataItem(title: "getConsentedOtherLiVendors", value: "Unknown"),
            ConsentDataItem(title: "getConsentedNonTcfPurposes", value: "Unknown"),
            ConsentDataItem(title: "getGoogleConsentMode", value: "Unknown")
        ]
    }
    
    // Update consent data values for list
    private func getConsentData() {
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
            ConsentDataItem(title: "checkConsentScope", value: consentScope),
            ConsentDataItem(title: "checkConsentState", value: consentState),
            ConsentDataItem(title: "checkConsentForPurpose(1)", value: consentForPurpose),
            ConsentDataItem(title: "checkConsentForVendor(9)", value: consentForVendor),
            ConsentDataItem(title: " ", value: " "),
            ConsentDataItem(title: "getTCString", value: tcString),
            ConsentDataItem(title: "getACString", value: acString),
            ConsentDataItem(title: "getGPPString", value: gppString),
            ConsentDataItem(title: "getConsentedTCFVendors", value: consentedTCFVendors),
            ConsentDataItem(title: "getConsentedTCFLiVendors", value: consentedTCFLiVendors),
            ConsentDataItem(title: "getConsentedTCFPurposes", value: consentedTCFPurposes),
            ConsentDataItem(title: "getConsentedTCFLiPurposes", value: consentedTCFLiPurposes),
            ConsentDataItem(title: "getConsentedGoogleVendors", value: consentedGoogleVendors),
            ConsentDataItem(title: "getConsentedOtherVendors", value: consentedOtherVendors),
            ConsentDataItem(title: "getConsentedOtherLiVendors", value: consentedOtherLiVendors),
            ConsentDataItem(title: "getConsentedNonTcfPurposes", value: consentedNonTcfPurposes),
            ConsentDataItem(title: "getGoogleConsentMode", value: googleConsentString)
        ]
    }
    
    private func clearUserDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            // Clear all UserDefaults
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
            print("UserDefaults storage cleared for bundle: \(bundleID)")
            showDefaultCMPOnLaunch = false
            // Refresh consent data after clearing
            getConsentData()
        }
    }
}

// MARK: - Preview
//struct ConsentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConsentView()
//    }
//}
