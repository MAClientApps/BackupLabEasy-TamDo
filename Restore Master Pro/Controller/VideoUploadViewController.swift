//
//  VideoUploadViewController.swift
//  Restore Master Pro
//
//  Created by Online on 28/09/22.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import AVKit
import AVFoundation

class VideoUploadViewController: UIViewController {

    @IBOutlet weak var videoUploadCollectionView: UICollectionView!
    
    var videoArr = [NSURL]()
    var videoImage = [UIImage]()
    var count = 0
    let isShowAd = AppDelegate.sharedInstance().mobFlow?.showAds() ?? true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        if let decodedURL  = UserDefaults.standard.object(forKey: "VideoURL") as? Data{
            do{
            
                videoArr = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decodedURL) as! [NSURL]
                UserDefaults.standard.synchronize()
                
            }catch{
                print(error.localizedDescription)
            }
        }
        setLayout()
        videoUploadCollectionView.reloadData()
    }
    
    func setLayout(){
        let layout =  CHTCollectionViewWaterfallLayout()
        videoUploadCollectionView.alwaysBounceVertical = true
        videoUploadCollectionView.collectionViewLayout = layout
    }
    
    
   @objc func shareData(_ sender: UIButton){
       let videoImage = videoArr[sender.tag]
       let filePath = "\(videoImage)/tmpVideo.mov"

       //saved
       
        let videoLink = NSURL(fileURLWithPath: filePath)
       
        let objectsToShare = [videoLink] //comment!, imageData!, myWebsite!]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        activityVC.setValue("Video", forKey: "subject")
        // New Excluded Activities Code
        if #available(iOS 9.0, *) {
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print ]
        } else {
            // Fallback on earlier versions
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print ]
        }

                   
        self.present(activityVC, animated: true, completion: nil)
    }
  
}

extension  VideoUploadViewController: UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoUploadCollectionViewCell", for: indexPath) as! VideoUploadCollectionViewCell
        
        let videoImage = videoArr[indexPath.row]
        do {
            let asset = AVURLAsset(url: videoImage as URL , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            cell.videoThumbnail.image = thumbnail
            
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
        }
        
        cell.shareBtn.tag = indexPath.row
        cell.shareBtn.addTarget(self, action: #selector(shareData(_:)), for: .touchUpInside)
        cell.indexValue = indexPath
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = Int.random(in: 50 ... 80)
        let height = Int.random(in: 80 ... 120)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isShowAd{
            AdsHelper.shared.showAd(self)
        }
        let videoUrl = videoArr[indexPath.row].absoluteString
        let url = URL(string: videoUrl!)

        let videoURL = url
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
}

extension VideoUploadViewController: VideoDeleteProtocol{

    func deleteCell(index: Int) {
        self.videoArr.remove(at: index)
        videoUploadCollectionView.reloadData()
        var newVideoArray = self.videoArr
        do{
            let encodedDataURL = try NSKeyedArchiver.archivedData(withRootObject: newVideoArray, requiringSecureCoding: false)
            UserDefaults.standard.set(encodedDataURL, forKey: "VideoURL")
            UserDefaults.standard.synchronize()
        }catch{
            print(error.localizedDescription)
        }
    }
}


  
 
