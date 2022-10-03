//
//  ImageUpload.swift
//  Restore Master Pro
//
//  Created by Online on 28/09/22.
//

import Foundation
import UIKit

class imageGetModel{
    var uid: String?
    var profileImageUrl: String?
    var id: String?
    var isFav: Bool?
    
    init(uid: String, profileImageUrl: String, id: String, isFav: Bool){
        self.uid = uid
        self.profileImageUrl = profileImageUrl
        self.id = id
        self.isFav = isFav
    }
}

class videoGetModel{
    var videoUrl: NSURL?
    var id: Int?
    
    init(videoUrl: NSURL, id: Int){
        self.videoUrl = videoUrl
        self.id = id
    }
}
