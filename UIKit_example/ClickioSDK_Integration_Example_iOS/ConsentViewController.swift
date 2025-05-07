//
//  ConsentViewController.swift
//  ClickioSDK_Integration_Example_iOS
//

import Foundation
import UIKit
import ClickioConsentSDKManager

// MARK: - ConsentViewController
class ConsentViewController: UIViewController {
    // MARK: Properties
    private let tableView = UITableView()
    private var consentData: [(title: String, value: String?)] = []
    private var openConsentButton: UIButton!
    
    // MARK: Set up SDK Consifuration
    private let config = ClickioConsentSDK.Config(siteId: "241131", appLanguage: "en") // Replace "241131" with your own Site ID
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Initialization of table with default "Unknown" values
        consentData = loadDefaultConsentData()
        
        // MARK: Set up event logger
        ClickioConsentSDK.shared.setLogsMode(.verbose)
        
        // MARK: Register callbacks before initialization
        ClickioConsentSDK.shared.onReady { [weak self] in
            guard let self = self else { return }
            self.openConsentButton.isEnabled = true
        }
        
        ClickioConsentSDK.shared.onConsentUpdated { [weak self] in
            guard let self = self else { return }
                DispatchQueue.main.async {
                    self.getConsentData()
                }
        }
        
        // MARK: Initialize SDK
        Task {
            await ClickioConsentSDK.shared.initialize(configuration: config)
        }
    }
    
    // MARK: Call WebView Dialog
    @objc private func openConsentWindow() {
        // MARK: If an app has it's own ATT Permission manager it just sends false in attNeeded parameter, calls it's own ATT method and then calls openDialog method.
        
        // MARK: Important: make sure that user has given permission in the ATT dialog and only then perfrom openDialog method call! Showing CMP regardles given ATT Permission is not recommended by Apple. Moreover, API calls to SDK's domains will be blocked by Apple until user provides their permission in ATT dialog. Otherwise it will lead to incorrect work of the SDK.
        
        // Example scenario with you custom ATT Manager:
//        DefaultAppATTManager.shared.requestPermission { isGrantedAccess in
//            if isGrantedAccess {
//                ClickioConsentSDK.shared.openDialog(
//                    mode: .resurface,
//                    in: self,
//                    attNeeded: false
//                )
//            } else {
//                print("Consent Dialog can't be shown: user rejected ATT permission")
//            }
//        }
         
        ClickioConsentSDK.shared.openDialog(
            mode: .resurface,
            in: self,
            attNeeded: true
        )
    }
    
    // MARK: Get consent data
    @objc private func getConsentData() {
        updateConsentData()
    }
    
    // MARK: Default consent data
    private func loadDefaultConsentData() -> [(title: String, value: String?)] {
        return [
            ("checkConsentScope", "Unknown"),
            ("checkConsentState", "Unknown"),
            ("checkConsentForPurpose(1)", "Unknown"),
            ("checkConsentForVendor(9)", "Unknown"),
            (" ", " "),
            ("getTCString", "Unknown"),
            ("getACString", "Unknown"),
            ("getGPPString", "Unknown"),
            ("getConsentedTCFVendors", "Unknown"),
            ("getConsentedTCFLiVendors", "Unknown"),
            ("getConsentedTCFPurposes", "Unknown"),
            ("getConsentedTCFLiPurposes", "Unknown"),
            ("getConsentedGoogleVendors", "Unknown"),
            ("getConsentedOtherVendors", "Unknown"),
            ("getConsentedOtherLiVendors", "Unknown"),
            ("getConsentedNonTcfPurposes", "Unknown"),
            ("getGoogleConsentMode", "Unknown")
        ]
    }
    
    private func updateConsentData() {
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
        
        // Update consent data
        consentData = [
            ("checkConsentScope", consentScope),
            ("checkConsentState", consentState),
            ("checkConsentForPurpose(1)", consentForPurpose),
            ("checkConsentForVendor(9)", consentForVendor),
            (" ", " "),
            ("getTCString", tcString),
            ("getACString", acString),
            ("getGPPString", gppString),
            ("getConsentedTCFVendors", consentedTCFVendors),
            ("getConsentedTCFLiVendors", consentedTCFLiVendors),
            ("getConsentedTCFPurposes", consentedTCFPurposes),
            ("getConsentedTCFLiPurposes", consentedTCFLiPurposes),
            ("getConsentedGoogleVendors", consentedGoogleVendors),
            ("getConsentedOtherVendors", consentedOtherVendors),
            ("getConsentedOtherLiVendors", consentedOtherLiVendors),
            ("getConsentedNonTcfPurposes", consentedNonTcfPurposes),
            ("getGoogleConsentMode", googleConsentString)
        ]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: UI set-up
    private func setupUI() {
        view.backgroundColor = .white

        openConsentButton = createButton(title: "Open Consent Dialog", action: #selector(openConsentWindow))
        openConsentButton.isEnabled = false
        
        let getConsentButton = createButton(title: "Refresh Consent Data", action: #selector(getConsentData))
        
        let buttonStack = UIStackView(arrangedSubviews: [openConsentButton, getConsentButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 10
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStack)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(ConsentCell.self, forCellReuseIdentifier: "ConsentCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}

// MARK: - UITableViewDataSource
extension ConsentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return consentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConsentCell", for: indexPath) as! ConsentCell
        let data = consentData[indexPath.row]
        cell.configure(title: data.title, value: data.value)
        return cell
    }
}

// MARK: - ConsentCell
class ConsentCell: UITableViewCell {
    // MARK: Properties
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    // MARK: Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods
    private func setupUI() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 0
        
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.textColor = .darkGray
        valueLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(title: String, value: String?) {
        titleLabel.text = title
        valueLabel.text = value ?? "null"
    }
}
