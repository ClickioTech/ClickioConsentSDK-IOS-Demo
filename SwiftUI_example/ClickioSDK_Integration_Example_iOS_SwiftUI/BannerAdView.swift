import SwiftUI
import GoogleMobileAds

// MARK: - BannerViewController
class BannerViewController: UIViewController {
    let bannerView = BannerView(adSize: AdSizeBanner)
    @AppStorage("enableAdUnitLogging") private var enableAdUnitLogging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create container view
        let containerView = UIView()
        containerView.backgroundColor = .clear
        view.addSubview(containerView)
        
        // Add banner view to container
        containerView.addSubview(bannerView)
        
        // Create horizontal stack for debug button and toggle
        let debugStack = UIStackView()
        debugStack.axis = .horizontal
        debugStack.spacing = 10
        debugStack.alignment = .center
        debugStack.distribution = .fill
        
        // Add debug button to stack
        let debugButton = UIButton(type: .system)
        debugButton.setTitle("Debug", for: .normal)
        debugButton.backgroundColor = .systemBlue
        debugButton.setTitleColor(.white, for: .normal)
        debugButton.layer.cornerRadius = 8
        debugButton.addTarget(self, action: #selector(openDebugOptions), for: .touchUpInside)
        debugStack.addArrangedSubview(debugButton)
        
        // Add toggle to stack
        let toggle = UISwitch()
        toggle.isOn = enableAdUnitLogging
        toggle.addTarget(self, action: #selector(toggleLogging(_:)), for: .valueChanged)
        debugStack.addArrangedSubview(toggle)
        
        // Add label for toggle
        let label = UILabel()
        label.text = "Ad verbose logging"
        label.font = .systemFont(ofSize: 14)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        debugStack.addArrangedSubview(label)
        
        containerView.addSubview(debugStack)
        
        // Set up constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        debugStack.translatesAutoresizingMaskIntoConstraints = false
        debugButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: AdSizeBanner.size.width),
            containerView.heightAnchor.constraint(equalToConstant: AdSizeBanner.size.height + 50),
            
            // Banner view constraints
            bannerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            bannerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            bannerView.widthAnchor.constraint(equalToConstant: AdSizeBanner.size.width),
            bannerView.heightAnchor.constraint(equalToConstant: AdSizeBanner.size.height),
            
            // Debug stack constraints
            debugStack.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 10),
            debugStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            debugStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            // Debug button constraints
            debugButton.widthAnchor.constraint(equalToConstant: 100),
            debugButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func toggleLogging(_ sender: UISwitch) {
        enableAdUnitLogging = sender.isOn
    }
    
    @objc func openDebugOptions() {
        // Create debug options view controller
        let debugOptionsViewController = DebugOptionsViewController(adUnitID: "/21775744923/example/fixed-size-banner")
        debugOptionsViewController.delegate = bannerView.delegate as? DebugOptionsViewControllerDelegate
        
        // Present the debug options view controller
        present(debugOptionsViewController, animated: true, completion: nil)
    }
}

// MARK: - BannerAdView
struct BannerAdView: UIViewControllerRepresentable {
    let adUnitID: String
    let shouldLoadAds: Bool
    
    func makeUIViewController(context: Context) -> BannerViewController {
        let viewController = BannerViewController()
        viewController.bannerView.adUnitID = adUnitID
        viewController.bannerView.rootViewController = viewController
        viewController.bannerView.delegate = context.coordinator
        
        // Get the window scene and its first window
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            if shouldLoadAds {
                print("BannerAdView: Loading ad in makeUIViewController")
                viewController.bannerView.load(Request())
            }
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: BannerViewController, context: Context) {
        if shouldLoadAds {
            print("BannerAdView: Loading ad in updateUIViewController")
            uiViewController.bannerView.load(Request())
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, BannerViewDelegate, DebugOptionsViewControllerDelegate {
        var debugOptionsViewController: DebugOptionsViewController?
        @AppStorage("enableAdUnitLogging") private var enableAdUnitLogging = false
        
        @objc func openDebugOptions() {
            // Create debug options view controller
            debugOptionsViewController = DebugOptionsViewController(adUnitID: "/21775744923/example/fixed-size-banner")
            debugOptionsViewController?.delegate = self
            
            // Present the debug options view controller
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(debugOptionsViewController!, animated: true, completion: nil)
            }
        }
        
        // MARK: - DebugOptionsViewControllerDelegate
        func debugOptionsViewControllerDidDismiss(_ controller: DebugOptionsViewController) {
            if enableAdUnitLogging {
                print("Debug options view controller dismissed")
            }
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            if enableAdUnitLogging {
                let nsError = error as NSError
                // Get error domain
                let errorDomain = nsError.domain
                // Get error code
                let errorCode = nsError.code
                // Get error message
                let errorMessage = error.localizedDescription
                // Get response info
                let responseInfo = nsError.userInfo[GADErrorUserInfoKeyResponseInfo] as? ResponseInfo
                // Get underlying error
                let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? Error
                
                print("""
                    Ad failed to load with error:
                    Domain: \(errorDomain)
                    Code: \(errorCode)
                    Message: \(errorMessage)
                    Response Info: \(responseInfo?.description ?? "nil")
                    Underlying Error: \(underlyingError?.localizedDescription ?? "nil")
                    """)
            }
        }
        
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            if enableAdUnitLogging {
                print("Ad successfully loaded")
                
                if let responseInfo = bannerView.responseInfo {
                    print("""
                        ** Response Info **
                        Response ID: \(responseInfo.responseIdentifier ?? "nil")
                        
                        ** Loaded Adapter Response **
                        Ad Source Name: \(responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? "nil")
                        Ad Source ID: \(responseInfo.loadedAdNetworkResponseInfo?.adSourceID ?? "nil")
                        Ad Source Instance Name: \(responseInfo.loadedAdNetworkResponseInfo?.adSourceInstanceName ?? "nil")
                        Ad Source Instance ID: \(responseInfo.loadedAdNetworkResponseInfo?.adSourceInstanceID ?? "nil")
                        AdUnitMapping: \(responseInfo.loadedAdNetworkResponseInfo?.adUnitMapping ?? [:])
                        Error: \(responseInfo.loadedAdNetworkResponseInfo?.error?.localizedDescription ?? "nil")
                        Latency: \(responseInfo.loadedAdNetworkResponseInfo?.latency ?? 0)
                        
                        ** Extras Dictionary **
                        \(responseInfo.extras)
                        
                        ** Mediation line items **
                        """)
                    
                    // Print all mediation line items
                    for (index, info) in responseInfo.adNetworkInfoArray.enumerated() {
                        print("""
                            Entry (\(index + 1))
                            Ad Source Name: \(info.adSourceName ?? "nil")
                            Ad Source ID: \(info.adSourceID ?? "nil")
                            Ad Source Instance Name: \(info.adSourceInstanceName ?? "nil")
                            Ad Source Instance ID: \(info.adSourceInstanceID ?? "nil")
                            AdUnitMapping: \(info.adUnitMapping ?? [:])
                            Error: \(info.error?.localizedDescription ?? "nil")
                            Latency: \(info.latency)
                            """)
                    }
                }
            }
        }
    }
}

#Preview {
    BannerAdView(adUnitID: "/21775744923/example/fixed-size-banner", shouldLoadAds: false)
} 