//
//  DataViewable.swift
//  DynamicCollectionView
//
//  Created by Stan Liu on 31/08/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import UIKit

// http://basememara.com/protocol-oriented-tableview-collectionview/

protocol Serviceable {
    
    func get(handler: [PicturePresentable] -> Void)
}

protocol DataViewable: class {
    
    func reloadData()
}

extension UICollectionView: DataViewable { }

protocol DataControllable: class {
    
    var dataView: DataViewable { get }
    var items: [PicturePresentable] { get set }
    var service: Serviceable { get }
}



extension DataControllable where Self: UIViewController {
    
    func didLoadPicture(delegate: DataControllable) {
        
        setupDataSource()
    }
    
    func setupDataSource() {
        
        service.get { (picture) in
            
            self.items = picture
            self.dataView.reloadData()
        }
    }
}
