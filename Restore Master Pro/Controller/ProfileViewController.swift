//
//  ProfileViewController.swift
//  Restore Master Pro
//
//  Created by Online on 28/09/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import ProgressHUD
import MobileCoreServices
import SDWebImage

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileFullImage: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var emailId: UILabel!
    @IBOutlet weak var smallProfilePage: UIImageView!
    
    var ref = DatabaseReference.init()
    var imagePicker = UIImagePickerController()
    var isProfileFectch: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let deleteImage = UIImage.gifImageWithName("trash")
        deleteBtn.setBackgroundImage(deleteImage, for: .normal)
        downloadimages()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfile(_:)))
        smallProfilePage.isUserInteractionEnabled = true
        smallProfilePage.addGestureRecognizer(tap)
        
        if let emailValue = UserDefaults.standard.object(forKey: "emailID"){
            emailId.text = emailValue as! String
        }
    }
    
    @objc func handleProfile(_ sender: UITapGestureRecognizer){
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.present(imagePicker, animated: true, completion: nil)
        }

    }
    
    private func downloadimages() {
        if let userUIID = UserDefaults.standard.object(forKey: "UserUUid"){
            let storageRef = Storage.storage().reference().child("myProfile.png").child(userUIID as! String)
                storageRef.downloadURL { (URL, error) in
                    if URL != nil {
                        self.profileFullImage.sd_setImage(with: URL)
                        self.smallProfilePage.sd_setImage(with: URL)
        
                    }else{
                        self.alert(message: "Set your Profile", title: "")
                    }
                    
                }
        }
    }
    
    func saveFirData(){
        self.uploadImageOnFirebase(self.smallProfilePage.image!){ url in
            self.showHud()
            if Auth.auth().currentUser != nil{
                guard let uid = Auth.auth().currentUser?.uid else {return}
                self.saveImageOnFirebase(uid: uid, profileUrl: url!){ success in
                    self.hideHUD()
                    if success{
                        if UserDefaults.standard.bool(forKey: "profileSet") == true{
                            self.isProfileFectch = true
                        }
                        self.alert(message: "Your Image Successfully Save.", title: "Congratulation")
                    }
                }
            }
        }
    }
    
    func uploadImageOnFirebase(_ image: UIImage, completion: @escaping ((_ url: URL?) -> ())){
        if let userUIID = UserDefaults.standard.object(forKey: "UserUUid"){
            
            let storageRef = Storage.storage().reference().child("myProfile.png").child(userUIID as! String)
            let imgData = smallProfilePage.image?.jpegData(compressionQuality: 0.75)
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
    
    func saveImageOnFirebase(uid: String, profileUrl: URL, completion: @escaping ((_ result : Bool)-> Void)){
        if Auth.auth().currentUser != nil{
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(false)
                return
            }
            let dict = ["uid": uid, "profileUrl": profileUrl.absoluteString ] as [String: Any]
            
            let db = Database.database().reference()
            let refchat = db.child("profileImage")
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
    
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "profileSet")
        UserDefaults.standard.synchronize()
        if Auth.auth().currentUser != nil{
            guard let uid = Auth.auth().currentUser?.uid else {return}
           let database = self.ref.child("profile").child(uid)
            database.removeValue()
            let profileDatabase = self.ref.child("profileImage").child(uid)
            profileDatabase.removeValue()
        }
    
        if let userDelete = Auth.auth().currentUser{
            userDelete.delete{ error in
                if let error = error {
                    print(error.localizedDescription)
                }else{
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
                }
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
       
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
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            self.smallProfilePage.image = image
            self.profileFullImage.image = image
            self.saveFirData()
        self.dismiss(animated: true, completion: nil)
    }
    
}
