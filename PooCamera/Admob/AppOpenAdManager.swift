//
//  AppOpenAdManager.swift
//  CalorieWalk2
//
//  Created by Wontai Ki on 3/4/25.
//

import GoogleMobileAds
import Foundation

class AppOpenAdManager: NSObject, FullScreenContentDelegate {
    var appOpenAd: AppOpenAd?
    var isLoadingAd = false
    var isShowingAd = false

    static let shared = AppOpenAdManager()

    private func loadAd() async {
        if isLoadingAd || isAdAvailable() {
            return
        }
        isLoadingAd = true

        do {
            appOpenAd = try await AppOpenAd.load(
              with: "ca-app-pub-6093046424339706/7961905015", request: Request())
            appOpenAd?.fullScreenContentDelegate = self
            showAdIfAvailable()
        } catch {
            print("App open ad failed to load with error: \(error.localizedDescription)")
        }
        isLoadingAd = false
    }

    func showAdIfAvailable() {
      // If the app open ad is already showing, do not show the ad again.
        guard !isShowingAd else { return }

        // If the app open ad is not available yet but is supposed to show, load
        // a new ad.
        if !isAdAvailable() {
            Task {
                await loadAd()
            }
            return
        }

        if let ad = appOpenAd {
            isShowingAd = true
            Task { @MainActor in
                ad.present(from: (currentUIWindow()?.rootViewController))
            }
        }
    }
    
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
            
    }

    private func isAdAvailable() -> Bool {
        // Check if ad exists and can be shown.
        return appOpenAd != nil
    }
    
    // MARK: - GADFullScreenContentDelegate methods

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("App open ad will be presented.")
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        appOpenAd = nil
        isShowingAd = false
        // Reload an ad.
//        Task {
//            await loadAd()
//        }
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        appOpenAd = nil
        isShowingAd = false
        // Reload an ad.
//        Task {
//            await loadAd()
//        }
    }
}
