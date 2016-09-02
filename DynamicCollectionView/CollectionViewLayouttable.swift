//
//  CollectionViewLayouttable.swift
//  DynamicCollectionView
//
//  Created by Stan Liu on 01/09/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import UIKit


protocol CollectionViewLayouttable {
    
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
}

class CollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var photoHeight: CGFloat = 0.0
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! CollectionViewLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let attributes = object as? CollectionViewLayoutAttributes {
            if attributes.photoHeight == photoHeight {
                return super.isEqual(object)
            }
        }
        return false
    }
}

class CollectionViewLayout: UICollectionViewLayout {
    
    var layouttable: CollectionViewLayouttable!
    
    var numberOfColumns = 2
    var cellPadding: CGFloat = 6.0
    
    // cache the calculated attributes. When you call prepareLayout(), you'll calculate the attributes for all items and add them to the cache. When the Collection view later requests the layout attributes, you can be efficent and query the cache instead of recalculating them every time.
    private var cache = [CollectionViewLayoutAttributes]()
    // Store the content size, contentHeight is incremented as photos are added, and contentWidth is calculate based on the collection view width and its content inset
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        
        let insets = collectionView!.contentInset
        return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return CollectionViewLayoutAttributes.self
    }
    
    override func prepareLayout() {
        // clean cache and do prepare again, otherwise it will only keep the first time of layout.
        cache.removeAll()
        // This is also, calculate the height everytime, otherwise it will keep the longest height after layout.
        contentHeight = 0.0
        
        // 1. Only calculate once
        if cache.isEmpty {
            
            // 2. Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )
            }
            var column = 0
            var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)

            
            // 3. Iterates through the list of items in the first section
            for item in 0 ..< collectionView!.numberOfItemsInSection(0) {
                
                let indexPath = NSIndexPath(forItem: item, inSection: 0)
                
                // 4. Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
                let width = columnWidth - cellPadding * 2
                let photoHeight = layouttable.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath , withWidth:width)
                let height = cellPadding +  photoHeight + cellPadding
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
                
                // 5. Creates an UICollectionViewLayoutItem with the frame and add it to the cache
                let attributes = CollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.photoHeight = photoHeight
                attributes.frame = insetFrame
                cache.append(attributes)
                
                // 6. Updates the collection view content height
                contentHeight = max(contentHeight, CGRectGetMaxY(frame))
                yOffset[column] = yOffset[column] + height
                column = column >= (numberOfColumns - 1) ? 0 : ++column
                //print("content height:\(contentHeight)")
            }
        }
    }
    
    func resetLayout() {
        
        cache.removeAll()
        prepareLayout()
        print("reset layout")
    }
    
    override func collectionViewContentSize() -> CGSize {
        
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}

