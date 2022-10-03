//
//  AdsHelper.swift
//  WallyUltra
//
//  Created by iOS Mobibox on 23/02/22.
//

import UIKit
import UnityAds

var showAdsAfterSearch = 3

class AdsHelper : NSObject
{
    let unityAdsID = "4954714"
    var delegate : AdHelperDelegate?
    var isRewardedVideoReady = false
    var isVideoReady = false
    var isBannerReady = false
    static let shared = AdsHelper()
    
    override init() {
        super.init()
   
    }
    
    deinit {
        print("de initializing successfull")
    }
    
    func initialise() {
        UnityAds.add(self)
        
#if DEBUG
        print("Not App Store build")
        //Test
        UnityAds.initialize(unityAdsID, testMode: true, initializationDelegate: self)
        UnityAds.setDebugMode(true)
#else
        //Live
        UnityAds.initialize(unityAdsID, initializationDelegate: self)
#endif
    }
    
    func showAd(_ controller: UIViewController) -> Bool
    {
        if self.isVideoReady
        {
            UnityAds.show(controller.self, placementId: "Interstitial_iOS", showDelegate: self)
            return true
        }
        else if self.isRewardedVideoReady
        {
            UnityAds.show(controller.self, placementId: "Rewarded_iOS", showDelegate: self)
            return true
        }
        return false
    }
    
    func showRewardedAd(_ controller: UIViewController) -> Bool
    {
        if self.isRewardedVideoReady
        {
            UnityAds.show(controller.self, placementId: "Rewarded_iOS", showDelegate: self)
            return true
        }
        else if self.isVideoReady
        {
            UnityAds.show(controller.self, placementId: "Interstitial_iOS", showDelegate: self)
            return true
        }
        return false
    }
    
    func showBanner(_ controller: UIViewController) -> Bool
    {
        if self.isBannerReady
        {
            UnityAds.show(controller.self, placementId: "Banner_iOS", showDelegate: self)
            return true
        }
        return false
    }
    
    func reset()
    {
        self.isRewardedVideoReady = false
        self.isVideoReady = false
        self.isBannerReady = false
    }
}

//MARK: UADSBannerView Delegate Methods
extension AdsHelper : UnityAdsInitializationDelegate, UnityAdsDelegate, UnityAdsShowDelegate
{
    func initializationComplete() {
        
    }
    
    func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
        
    }
    
    func unityAdsReady(_ placementId: String)
    {
        print("placementId: \(placementId)")
        if placementId == "Rewarded_iOS"
        {
            if !self.isRewardedVideoReady
            {
                self.isRewardedVideoReady = true
//                self.delegate?.unityAdsReady()
            }
        }
        else if placementId == "Interstitial_iOS"
        {
            if !self.isVideoReady
            {
                self.isVideoReady = true
//                self.delegate?.unityAdsReady()
            }
        }
        else if placementId == "Banner_iOS"
        {
            if !self.isBannerReady
            {
                self.isBannerReady = true
//                self.delegate?.unityBannerReady()
            }
        }
    }
    
    func unityAdsDidError(_ error: UnityAdsError, withMessage message: String)
    {
        
    }
    
    func unityAdsDidStart(_ placementId: String)
    {
        
    }
    
    func unityAdsDidFinish(_ placementId: String, with state: UnityAdsFinishState)
    {
        
    }
    
    func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState)
    {
        
    }
    
    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String)
    {
        
    }
    
    func unityAdsShowStart(_ placementId: String)
    {
        
    }
    
    func unityAdsShowClick(_ placementId: String)
    {
        
    }
}

protocol AdHelperDelegate
{
    func unityAdsReady()
    func unityBannerReady()
}

