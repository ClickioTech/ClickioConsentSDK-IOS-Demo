//
//  ConsentViewController.swift
//  ClickioSDK_Integration_Example_iOS
//

import UIKit
import AppTrackingTransparency
import ClickioConsentSDKManager
import GoogleMobileAds

// MARK: - ConsentViewController
final class ConsentViewController: UIViewController {
    // MARK: Properties
    private var lastConsentState: ClickioConsentSDK.ConsentState? = .gdprNoDecision
    private var showDefaultCMPOnLaunch = true
    private var shouldShowAdsBanner = false {
        didSet {
            guard let bannerVC = bannerViewController else { return }
            let bannerView = bannerVC.view!

            bannerView.isHidden = !shouldShowAdsBanner
            
            if shouldShowAdsBanner {
                bannerTop.isActive = true
                bannerHeight.isActive = true
                bannerBottom.isActive = true
                
                tableViewBottomToSafeArea.isActive = false
                tableViewBottomToBannerTop.isActive = true
                
                // load the ad
                bannerVC.bannerView.load(Request())
            } else {
                bannerTop.isActive = false
                bannerHeight.isActive = false
                bannerBottom.isActive = false
                
                tableViewBottomToBannerTop.isActive = false
                tableViewBottomToSafeArea.isActive = true
            }

            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }

    // UI Elements
    private let tableView = UITableView()
    private let verboseLoggingSwitch = UISwitch()
    private let verboseLoggingKey = "enableVerboseLogging"
    private let resurfaceModeButton = UIButton(type: .system)
    private let customWebViewButton = UIButton(type: .system)
    private let clearLocalStorageForWebView = UIButton(type: .system)
    private let refreshButton = UIButton(type: .system)
    private let clearDataButton = UIButton(type: .system)
    private var bannerViewController: BannerViewController?

    // Constraints
    private var tableViewBottomToSafeArea: NSLayoutConstraint!
    private var tableViewBottomToBannerTop: NSLayoutConstraint!
    private var bannerTop: NSLayoutConstraint!
    private var bannerHeight: NSLayoutConstraint!
    private var bannerBottom: NSLayoutConstraint!

    // Data
    private var consentData: [ConsentDataItem] = []

    // SDK Config
    private let config = ClickioConsentSDK.Config(siteId: "241131", appLanguage: "en") // Replace "241131" with your own Site ID

    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        loggerSwitcherSetup()
        setupUI()
        setupConsentSDK()
        consentData = defaultConsentData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if showDefaultCMPOnLaunch {
//            showDefaultCMPIfNeeded()
//        }
    }

    private func showDefaultCMPIfNeeded() {
        ClickioConsentSDK.shared.openDialog(
            mode: .default,
            in: self,
            attNeeded: true
        )
    }
    
    // MARK: - SDK Setup
    private func setupConsentSDK() {
        ClickioConsentSDK.shared.onReady { [weak self] in
            self?.resurfaceModeButton.isEnabled = true
            self?.customWebViewButton.isEnabled = true
            self?.clearLocalStorageForWebView.isEnabled = true
            self?.refreshButton.isEnabled = true
            self?.clearDataButton.isEnabled = true
            self?.getConsentData()
            self?.checkIfCanShowAds()
        }
        ClickioConsentSDK.shared.onConsentUpdated { [weak self] in
            guard let self = self else { return }
            checkIfCanShowAds()
            self.getConsentData()
        }
        Task {
            await ClickioConsentSDK.shared.initialize(configuration: config)
        }
    }
    
    // MARK: - Google Ads Check
    private func checkIfCanShowAds() {
        guard let state = ClickioConsentSDK.shared.checkConsentState() else {
            // no information about user decision available — do nothing
            return
        }
        // if we still have “no decision”, remember it and exit
        if state == .gdprNoDecision {
            lastConsentState = state
            return
        }
        // at this point state != .gdprNoDecision
        
        // ensure we’re actually transitioning from “noDecision” to (“gdprDecisionObtained” or other states)
        guard lastConsentState == .gdprNoDecision else {
            // if we were already in another state, do nothing
            return
        }
        // this block will run exactly once upon the first transition
        lastConsentState = state
        
        print("ConsentView: Consent state allows ads, showing Google Ads")
        shouldShowAdsBanner = true
    }
    
    // MARK: - Actions
    @objc private func toggleVerboseLogging() {
        let isOn = verboseLoggingSwitch.isOn
        UserDefaults.standard.set(isOn, forKey: verboseLoggingKey)
        ClickioConsentSDK.shared.setLogsMode(verboseLoggingSwitch.isOn ? .verbose : .disabled)
    }
    
    @objc private func openResurfaceConsent() {
        ClickioConsentSDK.shared.openDialog(
            mode: .resurface,
            in: self,
            attNeeded: true
        )
    }
    
    // MARK: Open custom webView
    @objc private func openCustomWebView() {
        let config = WebViewConfig(
            backgroundColor: .cyan
        )
        
        let webVC = ClickioConsentSDK.shared.webViewLoadUrl(
            urlString: "https://account.clickio.com/public/test/solveit-demo/tcf-global.html",
            config: config
        )

        webVCToRemove = webVC
        addChild(webVC)
        view.addSubview(webVC.view)
        webVC.didMove(toParent: self)

        // button for closing custom webView
        let closeViewButton = UIView()
        closeViewButton.backgroundColor = .red
        
        closeViewButton.translatesAutoresizingMaskIntoConstraints = false
        webVC.view.addSubview(closeViewButton)
        
        // Controller for webView setup
        webVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webVC.view.widthAnchor.constraint(equalToConstant: 350),
            webVC.view.heightAnchor.constraint(equalToConstant: 700),
            webVC.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            webVC.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            closeViewButton.widthAnchor.constraint(equalToConstant: 50),
            closeViewButton.heightAnchor.constraint(equalToConstant: 50),
            closeViewButton.topAnchor.constraint(equalTo: webVC.view.topAnchor),
            closeViewButton.trailingAnchor.constraint(equalTo: webVC.view.trailingAnchor)
        ])
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToCloseCustomWebView))
        closeViewButton.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Close custom webView
    var webVCToRemove: WebViewController?
    @objc func tapToCloseCustomWebView() {
        webVCToRemove?.view.removeFromSuperview()
    }
    
    // MARK: Clear Local Storage for WebView
    @objc func clearLocalStorage() {
        let dataStore = WKWebsiteDataStore.default()
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        let since = Date(timeIntervalSince1970: 0)
        
        dataStore.removeData(ofTypes: types, modifiedSince: since) {
            // clear URLCache
            URLCache.shared.removeAllCachedResponses()
            
            // clear cookie (httpCookieStore и HTTPCookieStorage)
            dataStore.httpCookieStore.getAllCookies { cookies in
                for cookie in cookies {
                    dataStore.httpCookieStore.delete(cookie)
                }
                
                DispatchQueue.main.async {
                    print("✅ Cleared WKWebsiteDataStore (types: \(types)), cookies, URLCache and UserDefaults")
                }
            }
        }
    }
    
    @objc private func getConsentData() {
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
        let googleConsentString = """
        Analytics Storage: \(googleConsentMode?.analyticsStorageGranted ?? false)
        Ad Storage: \(googleConsentMode?.adStorageGranted ?? false)
        Ad User Data: \(googleConsentMode?.adUserDataGranted ?? false)
        Ad Personalization: \(googleConsentMode?.adPersonalizationGranted ?? false)
        Functionality Storage: \(googleConsentMode?.functionalityStorageGranted ?? false)
        Personalization Storage: \(googleConsentMode?.personalizationStorageGranted ?? false)
        Security Storage: \(googleConsentMode?.securityStorageGranted ?? false)
        """
        
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
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc private func clearUserDefaults() {
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
            UserDefaults.standard.synchronize()
            getConsentData()
        }
    }
    
    // MARK: - LoggerSwitcher setup
    private func loggerSwitcherSetup() {
        let hasSetVerbose = UserDefaults.standard.object(forKey: verboseLoggingKey) != nil

           if !hasSetVerbose {
               UserDefaults.standard.set(true, forKey: verboseLoggingKey)
           }

           let savedLoggingMode = UserDefaults.standard.bool(forKey: verboseLoggingKey)
           verboseLoggingSwitch.isOn = savedLoggingMode
           ClickioConsentSDK.shared.setLogsMode(savedLoggingMode ? .verbose : .disabled)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Controls Stack
        let verboseLabel = UILabel()
        verboseLabel.text = "Enable Verbose Logging"
        let verboseStack = UIStackView(arrangedSubviews: [verboseLabel, verboseLoggingSwitch])
        verboseStack.axis = .horizontal
        verboseStack.spacing = 8
        verboseStack.translatesAutoresizingMaskIntoConstraints = false
        
        [resurfaceModeButton,
         customWebViewButton,
         clearLocalStorageForWebView,
         refreshButton,
         clearDataButton].forEach { btn in
            btn.backgroundColor = .systemBlue
            btn.setTitleColor(.white, for: .normal)
            btn.layer.cornerRadius = 8
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        
        resurfaceModeButton.setTitle("Resurface Mode", for: .normal)
        customWebViewButton.setTitle("Open Custom WebView", for: .normal)
        clearLocalStorageForWebView.setTitle("Clear local storage for webView", for: .normal)
        refreshButton.setTitle("Refresh Consent Data", for: .normal)
        clearDataButton.setTitle("Clear Data", for: .normal)
        
        resurfaceModeButton.addTarget(self, action: #selector(openResurfaceConsent), for: .touchUpInside)
        customWebViewButton.addTarget(self, action: #selector(openCustomWebView), for: .touchUpInside)
        clearLocalStorageForWebView.addTarget(self, action: #selector(clearLocalStorage), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(getConsentData), for: .touchUpInside)
        clearDataButton.addTarget(self, action: #selector(clearUserDefaults), for: .touchUpInside)
        verboseLoggingSwitch.addTarget(self, action: #selector(toggleVerboseLogging), for: .valueChanged)
        
        // TableView
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ConsentCell.self, forCellReuseIdentifier: ConsentCell.reuseID)
        
        let controlsStack = UIStackView(arrangedSubviews: [
            verboseStack,
            resurfaceModeButton,
            customWebViewButton,
            clearLocalStorageForWebView,
            refreshButton,
            clearDataButton
        ])
        controlsStack.axis = .vertical
        controlsStack.spacing = 12
        controlsStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(controlsStack)
        view.addSubview(tableView)
        
        // Banner VC setup (hidden initially)
        let bannerVC = BannerViewController()
        addChild(bannerVC)
        bannerVC.view.translatesAutoresizingMaskIntoConstraints = false
        bannerVC.view.isHidden = true
        view.addSubview(bannerVC.view)
        bannerVC.didMove(toParent: self)
        bannerViewController = bannerVC
        
        NSLayoutConstraint.activate([
            controlsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let bannerView = bannerVC.view!
        bannerTop = bannerView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16)
        bannerHeight = bannerView.heightAnchor.constraint(equalToConstant: AdSizeBanner.size.height + 50)
        bannerBottom = bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bannerView.widthAnchor.constraint(equalToConstant: AdSizeBanner.size.width)
        ])
        
        tableViewBottomToSafeArea = tableView
            .bottomAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        tableViewBottomToBannerTop = tableView
            .bottomAnchor
            .constraint(equalTo: bannerView.topAnchor, constant: -16)
        
        // default state for table without banner
        tableViewBottomToSafeArea.isActive = true
        tableViewBottomToBannerTop.isActive = false
    }
}

// MARK: - UITableViewDataSource
extension ConsentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return consentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConsentCell.reuseID, for: indexPath) as! ConsentCell
        let data = consentData[indexPath.row]
        cell.configure(title: data.title, value: data.value)
        return cell
    }
}
