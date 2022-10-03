//
//  VideoUploadCollectionViewCell.swift
//  Restore Master Pro
//
//  Created by Online on 28/09/22.
//

import UIKit

protocol VideoDeleteProtocol {
    func deleteCell(index: Int)
}


class VideoUploadCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var heartBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var downloadBtn: UIButton!
    
    var delegate: VideoDeleteProtocol?
    var indexValue: IndexPath?
    var likeDelegate: LikeImagesProtocol?
    
//    func configurecell(image: UIImage){
//        getImages.image = image
//    }
    @IBAction func deleteBtnAction(_ sender: Any) {
        delegate?.deleteCell(index: (indexValue?.row)!)
    }
    
    @IBAction func heartBtnClick(_ sender: Any) {
        likeDelegate?.likedCell(index: (indexValue?.row)!)
    }
}
