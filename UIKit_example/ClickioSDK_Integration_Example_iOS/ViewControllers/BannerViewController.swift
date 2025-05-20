//
//  BannerViewController.swift
//  ClickioSDK_Integration_Example_iOS
//

import UIKit
import GoogleMobileAds

// MARK: - BannerViewController
final class BannerViewController: UIViewController {
    // MARK: Properties
    private let containerView = UIView()
    let bannerView = BannerView(adSize: AdSizeBanner)
    private let debugButton = UIButton(type: .system)
    private let loggingSwitch = UISwitch()
    private let loggingLabel = UILabel()
    private let loggingKey = "enableAdUnitLogging"
    private var enableVerboseLogging: Bool {
        get { UserDefaults.standard.bool(forKey: loggingKey) }
        set { UserDefaults.standard.set(newValue, forKey: loggingKey) }
    }

    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        // Container
        containerView.backgroundColor = .clear
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Banner
        bannerView.adUnitID = "/21775744923/example/fixed-size-banner"
        bannerView.rootViewController = self
        bannerView.delegate = self
        containerView.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        // Debug UI
        debugButton.setTitle("Debug", for: .normal)
        debugButton.backgroundColor = .systemBlue
        debugButton.setTitleColor(.white, for: .normal)
        debugButton.layer.cornerRadius = 8
        debugButton.addTarget(self, action: #selector(openDebugOptions), for: .touchUpInside)

        loggingSwitch.isOn = enableVerboseLogging
        loggingSwitch.addTarget(self, action: #selector(toggleLogging(_:)), for: .valueChanged)

        loggingLabel.text = "Ad verbose logging"
        loggingLabel.font = .systemFont(ofSize: 14)
        loggingLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [debugButton, loggingSwitch, loggingLabel])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        containerView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        debugButton.translatesAutoresizingMaskIntoConstraints = false

        // Constraints
        let size = AdSizeBanner.size
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: size.width),
            containerView.heightAnchor.constraint(equalToConstant: size.height + 50),

            bannerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            bannerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            bannerView.widthAnchor.constraint(equalToConstant: size.width),
            bannerView.heightAnchor.constraint(equalToConstant: size.height),

            stack.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),

            debugButton.widthAnchor.constraint(equalToConstant: 100),
            debugButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Load ad
        bannerView.load(Request())
    }

    @objc private func toggleLogging(_ sender: UISwitch) {
        enableVerboseLogging = sender.isOn
    }

    @objc private func openDebugOptions() {
        let debugVC = DebugOptionsViewController(adUnitID: bannerView.adUnitID!)
        debugVC.delegate = self
        present(debugVC, animated: true)
    }
}

// MARK: - BannerViewDelegate
extension BannerViewController: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        if enableVerboseLogging {
            print("Ad loaded; responseInfo = \(String(describing: bannerView.responseInfo))")
        }
    }
    func bannerView(_ bannerView: BannerView,
                    didFailToReceiveAdWithError error: Error) {
        if enableVerboseLogging {
            print("Ad failed to load: \(error.localizedDescription)")
        }
    }
}

// MARK: - DebugOptionsViewControllerDelegate
extension BannerViewController: DebugOptionsViewControllerDelegate {
    func debugOptionsViewControllerDidDismiss(_ controller: DebugOptionsViewController) {
        if enableVerboseLogging {
            print("Debug dialog dismissed")
        }
    }
}
