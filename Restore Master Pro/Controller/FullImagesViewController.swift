//
//  FullImagesViewController.swift
//  Restore Master Pro
//
//  Created by Online on 28/09/22.
//

import UIKit
import AnimatedCollectionViewLayout
import SDWebImage

class FullImagesViewController: UIViewController {

    @IBOutlet weak var fullImageCollectionView: UICollectionView!
    
    var imageUrlArray: [imageGetModel] = []
    var startIndexpath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        
        fullImageCollectionView.reloadData()
        fullImageCollectionView.layoutIfNeeded()
        fullImageCollectionView.scrollToItem(at: startIndexpath, at: .centeredHorizontally, animated: true)
        fullImageCollectionView.isPagingEnabled = true
        
    }

    
    func setLayout(){
        let layout =  AnimatedCollectionViewLayout()
        layout.animator = PageAttributesAnimator()
        layout.scrollDirection = .horizontal
        fullImageCollectionView.collectionViewLayout = layout
    }

}

extension  FullImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrlArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoUploadCollectionViewCell", for: indexPath) as! VideoUploadCollectionViewCell
        let urlOfImage = imageUrlArray[indexPath.row].profileImageUrl
        if let url = URL(string: urlOfImage!){
            cell.videoThumbnail.sd_setImage(with: url)
        }
        
        cell.shareBtn.tag = indexPath.row
        cell.downloadBtn.tag = indexPath.row
    
        cell.shareBtn.addTarget(self, action: #selector(shareBtnAction(_:)), for: .touchUpInside)
        cell.downloadBtn.addTarget(self, action: #selector(downloadBtnAction(_:)), for: .touchUpInside)
        
        let fav = imageUrlArray[indexPath.row].isFav
        if fav == true{
            cell.heartBtn.setBackgroundImage(UIImage(named: "heartRed"), for: .normal)
        }else{
            cell.heartBtn.setBackgroundImage(UIImage(named: "heartGray"), for: .normal)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        let height = self.view.frame.height
        return CGSize(width: width, height: height)
    }
    
    @objc func shareBtnAction(_ sender: UIButton){
        let urlOfImage = imageUrlArray[sender.tag].profileImageUrl
        let objectsToShare:URL = URL(string: urlOfImage!)!
            let sharedObjects:[AnyObject] = [objectsToShare as AnyObject]
            let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view

        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail]
            self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func downloadBtnAction(_ sender: UIButton){
        let urlOfImage = imageUrlArray[sender.tag].profileImageUrl
        downloadImage(url: urlOfImage!)
    }
    
    func downloadImage(url: String) {
        guard let imageUrl = URL(string: url) else { return }
        getDataFromUrl(url: imageUrl) { data, _, _ in
            DispatchQueue.main.async() {
                let activityViewController = UIActivityViewController(activityItems: [data ?? ""], applicationActivities: nil)
                activityViewController.modalPresentationStyle = .fullScreen
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }.resume()
    }
}


