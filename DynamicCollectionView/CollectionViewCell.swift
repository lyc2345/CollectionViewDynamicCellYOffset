//
//  CollectionViewCell.swift
//  DynamicCollectionView
//
//  Created by Stan Liu on 31/08/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell, DemoPhotoDownloadable {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewheightLayoutConstraint: NSLayoutConstraint!
    
    var urlString: String?
    var image: UIImage? {
        
        didSet {
            
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
    
    func bind(withPresenter presenter: PicturePresentable, completion: Void -> Void) {
        
        self.urlString = presenter.urlString
        /*
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            
            guard let url = self.urlString else {
                
                return
            }
            
            self.fetchImage(url) { (resultData: Result<NSData>) in
                
                let imageResult = resultData.flatMap(self.buildDemoPhoto).flatMap(self.readImage)
                
                do {
                    
                    let image = try imageResult.resolve()
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.image = image
                    })

                } catch {
                    print("Error: \(error)")
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion()
            })
        }*/
    }
//    
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

