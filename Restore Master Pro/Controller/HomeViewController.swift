//
//  HomeViewController.swift
//  Restore Master Pro
//
//  Created by Online on 27/09/22.
//

import UIKit
import MobileCoreServices
import ProgressHUD
import Firebase
import FirebaseAuth
import FirebaseStorage
import AVFoundation
import OpalImagePicker
import Photos

class HomeViewController: UIViewController {

    @IBOutlet weak var cameraGIF: UIImageView!
    @IBOutlet weak var galleryGIF: UIImageView!
    @IBOutlet weak var videoGIF: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var buttonTag = 0
    var photoRecover: UIImage?
    var ref = DatabaseReference.init()
    var uploadImageArray: [UIImage] = []
    let imagePicker = UIImagePickerController()
    var videoUrl: NSURL?
    var videoArray = [NSURL]()
    var videoImage = [UIImage]()
    let isShowAd = AppDelegate.sharedInstance().mobFlow?.showAds() ?? true
    var adTimer : Timer?
    
    var tabController: VC_TYPE = .Dummy
    override func viewDidLoad() {
      super.viewDidLoad()
        
        gifCall()
        
        if (isShowAd) {
            AdsHelper.shared.initialise()
        }
        
        let userName = UserDefaults.standard.object(forKey: "UserName")
        
        if userName as! String == ""{
            userNameLabel.text = ""
        }else{
            userNameLabel.text = "\(userName!),"
        }
        
    }
    
    func gifCall(){
        self.ref = Database.database().reference()
        
        cameraGIF.image = UIImage.gifImageWithName("Camera")
        galleryGIF.image = UIImage.gifImageWithName("Gallery")
        videoGIF.image = UIImage.gifImageWithName("Video")
    }
  
    func uploadImageOnFirebaseWithImagePicker(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            imagePicker.isEditing = true
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func getAssetThumbnail(assets: [PHAsset]) -> [UIImage] {
          var arrayOfImages = [UIImage]()
          for asset in assets {
              let manager = PHImageManager.default()
              let option = PHImageRequestOptions()
              var image = UIImage()
              option.isSynchronous = true
              manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                  image = result!
                  arrayOfImages.append(image)
              })
          }
          return arrayOfImages
      }
    
    
    func uploadImageOnFirebaseWithImagePickerUsingCamera(){
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController(title: nil, message: "Device has no camera.", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "Alright", style: .default, handler: { (alert: UIAlertAction!) in
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.callAlertView(message: "Want Upload Click Images", title: "Alert")
        }
    }
    
    func callAlertView(message: String, title: String){
        let imagePicker = UIImagePickerController()
        let alertController = UIAlertController(title: "title", message: message, preferredStyle: .alert)

        let uploadImages = UIAlertAction(title: "Upload", style: .default, handler: { (alert: UIAlertAction!) in
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.isEditing = true
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.present(imagePicker, animated: true, completion: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) in
        })
        alertController.addAction(uploadImages)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func saveFirData(selectedImages: UIImage){
        self.uploadImageOnFirebase(selectedImages){ url in
            self.showHud()
            if Auth.auth().currentUser != nil{
                guard let uid = Auth.auth().currentUser?.uid else {return}
                self.saveImageOnFirebase(uid: uid, profileUrl: url!, isFav: false){ success in
                    self.hideHUD()
                    if success{
                        self.alert(message: "Your Image Successfully Save.", title: "Congratulation")
                    }
                }
            }
        }
    }
    
    func pickupTheVideosInApp(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraAction(_ sender: Any) {
        buttonTag = (sender as AnyObject).tag
        self.uploadImageOnFirebaseWithImagePickerUsingCamera()
    }
    
    
    @IBAction func galleryAction(_ sender: Any) {
        buttonTag = (sender as AnyObject).tag
        self.uploadImageOnFirebaseWithImagePicker()
    }
    
    @IBAction func videoUploadAction(_ sender: Any) {
        buttonTag = (sender as AnyObject).tag
        self.pickupTheVideosInApp()
    }
    
    @IBAction func favouriteBtnAction(_ sender: Any) {
        
        let vc = restoreStoryboard.instantiateViewController(withIdentifier: "FavouriteViewController") as! FavouriteViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func logoutBtnAction(_ sender: Any) {
        if Auth.auth().currentUser != nil{
            do{
                try Auth.auth().signOut()
              
                let vc = restoreStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                UserDefaults.standard.set("", forKey: "UserUUid")
                UserDefaults.standard.set("", forKey: "VideoURL")
                UserDefaults.standard.set(false, forKey: "HeartClick")
                UserDefaults.standard.set(false, forKey: "profileSet")
                UserDefaults.standard.set("", forKey: "UserName")
                UserDefaults.standard.set(false, forKey: "FirstTimeUserLogin")
                UserDefaults.standard.set("", forKey: "emailID")
                UserDefaults.standard.synchronize()
                let navigationController = UINavigationController(rootViewController: vc)
                let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                keyWindow?.rootViewController = navigationController
                keyWindow?.makeKeyAndVisible()
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }
    }
    
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if buttonTag == 1{
            let getImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            self.photoRecover = getImage
            self.saveFirData(selectedImages: self.photoRecover!)
        }else if buttonTag == 2{
            let getImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            self.photoRecover = getImage
            self.saveFirData(selectedImages: self.photoRecover!)
        }else if buttonTag == 3{
            if let pickedVideo = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL{
                videoUrl = pickedVideo
                videoArray.append(videoUrl!)
                do{
                    let encodedDataURL = try NSKeyedArchiver.archivedData(withRootObject: videoArray, requiringSecureCoding: false)
                    UserDefaults.standard.set(encodedDataURL, forKey: "VideoURL")
                    UserDefaults.standard.set(false, forKey: "HeartClick")
                    UserDefaults.standard.synchronize()
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
  
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension HomeViewController{
    func uploadImageOnFirebase(_ image: UIImage, completion: @escaping ((_ url: URL?) -> ())){

        if let userUIID = UserDefaults.standard.object(forKey: "UserUUid"){
            let storageRef = Storage.storage().reference().child("myImgage.png").child(userUIID as! String)
            let imgData = self.photoRecover?.jpegData(compressionQuality: 0.75)
            var imageSize: Int = imgData!.count
            print(" Convert Into KB: \(Double(imageSize/1000))")
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
           storageRef.putData(imgData!, metadata: metaData, completion: { (metadata, error) in
                if error == nil{
                    print("success")
                    storageRef.downloadURL(completion: { (url, error) in
                        completion(url)
                    })
                }else{
                    print(error.debugDescription)
                    completion(nil)
                }
            })
        }
    }

    func saveImageOnFirebase(uid: String, profileUrl: URL, isFav: Bool , completion: @escaping ((_ result : Bool)-> Void)){
        if Auth.auth().currentUser != nil{
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(false)
                return
            }
            let dict = ["uid": uid, "profileUrl": profileUrl.absoluteString , "idFavourite": isFav ] as [String: Any]
            let db = Database.database().reference()
            let refchat = db.child("profile")

            let refChatValue = refchat.childByAutoId()
            let currentUserId = uid
            let refUser = refchat.child(currentUserId)
            let userKey = refChatValue.key
            let refUserChatId = refUser.child(userKey!)
            refUserChatId.setValue(dict)
            
            
            completion(true)
        } else {
            completion(false)
        }
    }
}


