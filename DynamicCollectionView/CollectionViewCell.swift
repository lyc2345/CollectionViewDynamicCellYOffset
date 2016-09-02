//
//  CollectionViewCell.swift
//  DynamicCollectionView
//
//  Created by Stan Liu on 31/08/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import UIKit
import Kingfisher

class CollectionViewCell: UICollectionViewCell, DemoPhotoDownloadable {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewheightLayoutConstraint: NSLayoutConstraint!
    
    var urlString: String?
    var image: UIImage? {
        
        didSet {
            self.imageView.layer.cornerRadius = 5
            self.imageView.layer.masksToBounds = true
            guard let image = self.image, _ = imageView else {
                return
            }
            self.imageView.image = image
        }
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        if let attributes = layoutAttributes as? CollectionViewLayoutAttributes {
            imageViewheightLayoutConstraint.constant = attributes.photoHeight
        }
    }
}

extension CollectionViewCell {
    
    func bind(withPresenter presenter: PicturePresentable, completion: (image: UIImage) -> Void) {
        
        self.urlString = presenter.urlString
        guard let string = self.urlString, URL = NSURL(string: string) else {
            
            fatalError()
        }
        self.imageView.kf_setImageWithURL(URL, placeholderImage: nil, optionsInfo: [], progressBlock: { receivedSize, totalSize in
            //print("\(indexPath.row): \(receivedSize)/\(totalSize)")
            
            }, completionHandler: { image, error, cacheType, imageURL in
                
                if let i = image {
                    completion(image: i)
                }
                //print("\(indexPath.row): Finished")
        })
        /*
        fetchImage(string) { (resultData) in
            
            do {
                let image = try resultData.flatMap(self.buildDemoPhoto).flatMap(self.readImage).resolve()
                completion(image: image)
            } catch {
                print("Error: \(error)")
            }
        }*/
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        urlString = nil
        imageView.image = nil
    }
}

extension UIImage {
    
    var decompressedImage: UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        drawAtPoint(CGPointZero)
        let decompressedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return decompressedImage
    }
}

