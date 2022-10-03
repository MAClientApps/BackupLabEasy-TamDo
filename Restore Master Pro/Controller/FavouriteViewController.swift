//
//  FavouriteViewController.swift
//  Restore Master Pro
//
//  Created by Online on 30/09/22.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import Firebase
import FirebaseAuth
import FirebaseStorage
import ProgressHUD
import SDWebImage

class FavouriteViewController: UIViewController {

    @IBOutlet weak var favouriteCollectionView: UICollectionView!
    
    var ref = DatabaseReference.init()
    var arrData = [imageGetModel]()
    var imageUrl: String?
    var uniqueId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = Database.database().reference()
        self.getAllImagsFromFirebase()
        setLayout()
    }
    
    func setLayout(){
        let layout =  CHTCollectionViewWaterfallLayout()
        favouriteCollectionView.alwaysBounceVertical = true
        favouriteCollectionView.collectionViewLayout = layout
    }
    
    func getAllImagsFromFirebase(){
        self.showHud()
        if Auth.auth().currentUser != nil{
            guard let uid = Auth.auth().currentUser?.uid else {return}
            self.ref.child("profile").child(uid).queryOrderedByKey().observe(.value, with: { (snapshot) in
                print(self.ref.child("profile").child(uid))
                self.arrData.removeAll()
                self.hideHUD()
                if let snapShot = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in snapShot {
                        if let mainDict = snap.value as? [String: AnyObject]{
                            let key = snap.key
                            let isFav = mainDict["idFavourite"] as? Bool
                            let uid = mainDict["uid"] as? String
                            let profilrImageUrl = mainDict["profileUrl"] as? String ?? ""
                            
                            if isFav == true{
                                self.arrData.append(imageGetModel(uid: uid!, profileImageUrl: profilrImageUrl, id: key, isFav: isFav!))
                            }
                            print(self.arrData)
                            self.favouriteCollectionView.reloadData()
                        }
                    }
                }
            }, withCancel: { (error) in
                print(error)
            })
        }
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
extension  FavouriteViewController: UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.arrData.count == 0{
            self.showHud()
        }else{
            self.hideHUD()
        }
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadedImagesCollectionViewCell", for: indexPath) as! UploadedImagesCollectionViewCell
        imageUrl = arrData[indexPath.row].profileImageUrl
        let url = URL(string: imageUrl!)
        cell.uploadedImages.sd_setImage(with: url)
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteApply(_:)), for: .touchUpInside)
        cell.indexValue = indexPath
        cell.delegate = self
        let fav = arrData[indexPath.row].isFav
        if fav == true{
            cell.heartBtn.setBackgroundImage(UIImage(named: "heartRed"), for: .normal)
            }
            else{
                cell.heartBtn.setBackgroundImage(UIImage(named: "heartGray"), for: .normal)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = Int.random(in: 50 ... 80)
        let height = Int.random(in: 80 ... 120)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingFor section: Int) -> CGFloat {
        return 30
    }
    
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = restoreStoryboard.instantiateViewController(withIdentifier: "FullImagesViewController") as! FullImagesViewController
        vc.imageUrlArray = arrData
        vc.startIndexpath = indexPath
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func deleteApply(_ sender: UIButton){
        let value = sender.tag
        print(self.arrData.count)
        self.showHud()
        if let currentClickUrl = self.arrData[sender.tag].profileImageUrl{
            if Auth.auth().currentUser != nil{
                guard let uid = Auth.auth().currentUser?.uid else {return}
                self.ref.child("profile").child(uid).observe(.value) { (snapshot) in
                    if let posts = snapshot.value as? [String: AnyObject] {
                        for (key, postReference) in posts {
                            if let post = postReference as? [String: Any]
                            {
                                let urlOfImage = post["profileUrl"] as? String
                                if urlOfImage == currentClickUrl{
                                    self.ref.child("profile").child(uid).child(key).removeValue(completionBlock: { (error, _) in
                                        DispatchQueue.main.async {
                                            self.getAllImagsFromFirebase()
                                            self.favouriteCollectionView.reloadData()
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension FavouriteViewController: LikeImagesProtocol{
    func likedCell(index: Int) {
        uniqueId = arrData[index].id!
        let isFav = arrData[index].isFav
        
        if isFav == false{
            if Auth.auth().currentUser != nil{
                guard let uid = Auth.auth().currentUser?.uid else {return}
                let updateFav = self.ref.child("profile").child(uid).child(uniqueId)
                updateFav.updateChildValues(["idFavourite": true])
                DispatchQueue.main.async {
                    self.getAllImagsFromFirebase()
                }
            }
            
        }else{
            if Auth.auth().currentUser != nil{
                guard let uid = Auth.auth().currentUser?.uid else {return}
                let updateFav = self.ref.child("profile").child(uid).child(uniqueId)
                updateFav.updateChildValues(["idFavourite": false])
                DispatchQueue.main.async {
                    self.getAllImagsFromFirebase()
                }
            }
        }
    }
}



