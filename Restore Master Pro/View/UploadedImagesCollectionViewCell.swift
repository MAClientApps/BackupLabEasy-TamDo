//
//  UploadedImagesCollectionViewCell.swift
//  Restore Master Pro
//
//  Created by Online on 28/09/22.
//

import UIKit

protocol LikeImagesProtocol {
    func likedCell(index: Int)
}

class UploadedImagesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var heartBtn: UIButton!
    @IBOutlet weak var uploadedImages: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var delegate: LikeImagesProtocol?
    var indexValue: IndexPath?
    
    @IBAction func heartBtnCLick(_ sender: Any) {
        heartBtn.isSelected = !heartBtn.isSelected
        if((heartBtn.isSelected)){
            heartBtn.setBackgroundImage(UIImage(named: "heartRed"), for: .normal)
                 delegate?.likedCell(index: (indexValue?.row)!)
        }
        else{
            heartBtn.setBackgroundImage(UIImage(named: "heartGray"), for: .normal)
            delegate?.likedCell(index: (indexValue?.row)!)
        }
         
    }
    
}
