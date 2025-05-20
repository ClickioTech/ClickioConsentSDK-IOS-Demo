//
//  ConsentDataItem.swift
//  ClickioSDK_Integration_Example_iOS
//

// MARK: - ConsentDataItem
public struct ConsentDataItem {
    let title: String
    let value: String?
}

public func defaultConsentData() -> [ConsentDataItem] {
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
        ConsentDataItem(title: "getGoogleConsentMode", value: "Unknown"),
    ]
}
