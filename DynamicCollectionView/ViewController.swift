//
//  ViewController.swift
//  DynamicCollectionView
//
//  Created by Stan Liu on 31/08/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import UIKit
import AVFoundation

struct MyService: Serviceable {
   
   init() { }
   
   func get(handler: [PicturePresentable] -> Void) {
      // TODO: Get real data from web service or database
      // i.e., Alamofire, Realm, etc
      handler([
         
         Picture(url: "https://i.ytimg.com/vi/y8TnvF_yZFo/maxresdefault.jpg"),
         Picture(url: "http://i.dailymail.co.uk/i/pix/2015/05/24/12/1E92AD9700000578-3094869-image-m-22_1432466314461.jpg"),
         Picture(url: "https://nyoobserver.files.wordpress.com/2016/03/gettyimages-479779618.jpg?quality=80&w=635"),
         Picture(url: "https://upload.wikimedia.org/wikipedia/commons/b/b8/Maria_Sharapova_2011.jpg"),
         Picture(url: "http://media.melty.es/article-2624526-ajust_930/maria-sharapova-muy-sexy.jpg"),
         Picture(url: "http://www.sportal.co.nz/di/library/sportal_com_au/d0/5/sharapova_l09dkqe3zfhp1ae26zqtq3vdl.jpg?t=-812252380&w=940"),
         Picture(url: "http://www.celebritiesmoney.com/wp-content/uploads/2014/11/Maria-Sharapova-richest-tennis-player.jpg"),
         Picture(url: "http://images.thehollywoodgossip.com/iu/s--C1HqS7-K--/t_full/f_auto,fl_lossy,q_75/v1372184404/maria-sharapova-bikini-photo.jpg"),
         Picture(url: "http://mms.businesswire.com/media/20160112006430/en/504170/5/Maria_Sharapova.jpg"),
         Picture(url: "http://media1.santabanta.com/full1/Lawn%20Tennis/Maria%20Sharapova/maria-sharapova-87a.jpg"),
         Picture(url: "http://ppcorn.com/us/wp-content/uploads/sites/14/2016/02/Maria-Sharapova-2-ppcorn.jpg"),
         Picture(url: "https://usatthebiglead.files.wordpress.com/2013/05/maria-sharapova-small.png"),
         Picture(url: "https://upload.wikimedia.org/wikipedia/commons/8/8d/Flickr_-_Carine06_-_Maria_Sharapova_(1).jpg"),
         Picture(url: "http://tg.la7.it/sites/default/files/news/mediagallery/08/06/2016/sharapova-9.jpg"),
         Picture(url: "http://www.speakerscorner.me/wp-content/uploads/2016/02/maria14-1.jpg"),
         Picture(url: "http://media.santabanta.com/wall2009/LawnTennis/Maria%20Sharapova/480x640/Maria-Sharapova-12447.jpg"),
         Picture(url: "http://roidvisor.com/wp-content/uploads/2016/03/maria-sharapova-700x300.jpg"),
         Picture(url: "http://mms.businesswire.com/media/20160112006430/en/504170/5/Maria_Sharapova.jpg"),
         Picture(url: "http://www.thecoveteur.com/wp-content/uploads/2016/01/Nike_Maria_Sharapova-83-1-728x684.jpg"),
         Picture(url: "https://cdn3.img.sputniknews.com/images/103639/75/1036397539.jpg"),
         Picture(url: "http://i.dailymail.co.uk/i/pix/2016/05/26/15/34A397DF00000578-0-The_29_year_old_Sharapova_was_included_in_the_Russian_Olympic_te-a-17_1464274411186.jpg"),
         Picture(url: "http://3.bp.blogspot.com/-sF0IHjRPlZ0/UrxbSy2UNSI/AAAAAAAAaeI/oz0vPnegUVk/s1600/Maria+Sharapova+Desktop+Backgrounds.jpg"),
         Picture(url: "http://images.thehollywoodgossip.com/iu/s--KvJTwF-d--/t_full/f_auto,fl_lossy,q_75/v1376594236/maria-sharapova-bikini-pic.jpg"),
         Picture(url: "http://speakerdata.s3.amazonaws.com/photo/image/846693/maria-sharapova-22924-2560x1440.jpg"),
         Picture(url: "http://i.dailymail.co.uk/i/pix/2015/02/22/25EFFB6300000578-2964075-image-m-7_1424624131011.jpg"),
         Picture(url: "http://www.hawtcelebs.com/wp-content/uploads/2015/11/maria-sharapova-for-esquire-photoshoot_1.jpg"),
         Picture(url: "http://press.porsche.com/media/gallery2/d/17788-1/Maria+Sharapova+with+Panamera+S+E-Hybrid.jpg")
         
         
         /*
          Picture(url: "IMG_7744"),
          Picture(url: "IMG_7753"),
          Picture(url: "IMG_7758"),
          Picture(url: "IMG_7749"),
          Picture(url: "IMG_7763"),
          Picture(url: "IMG_7750")*/
         ].flatMap { $0 as Picture })
   }
}

// https://www.raywenderlich.com/107439/uicollectionview-custom-layout-tutorial-pinterest
// http://www.raywenderlich.com/wp-content/uploads/2015/05/customlayout-calculations1.png

class ViewController: UIViewController, DataControllable, DemoPhotoDownloadable {
   
   @IBOutlet weak var collectionView: UICollectionView!
   
   var dataView: DataViewable { return collectionView }
   var service: Serviceable = MyService()
   var items: [PicturePresentable] = []
   var demoPhoto: [DemoPhoto] = []
   
   var currentDownloadIndex = 0
   var images: [UIImage?] = []
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      collectionView.delegate = self
      
      didLoadPicture(self as DataControllable)
      
      let layout = CollectionViewLayout()
      
      collectionView.collectionViewLayout = layout
      layout.layouttable = self
      
      collectionView.backgroundColor = UIColor.clearColor()
      collectionView.contentInset = UIEdgeInsets(top: 43, left: 5, bottom: 10, right: 5)
      
      downloadImage()
   }
   
   func downloadImage() {
      
      dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
         
         for i in 0 ..< self.items.count {
            
            guard let url = self.items[i].urlString as? String else {
               
               return
            }
            
            self.fetchImage(url) { (resultData: Result<NSData>) in
               
               let imageResult = resultData.flatMap(self.buildDemoPhoto).flatMap(self.readImage)
               
               do {
                  
                  let image = try imageResult.resolve()
                  self.images.append(image)
                  dispatch_async(dispatch_get_main_queue(), {
                     self.updateCellSize()
                  })
                  
               } catch {
                  print("Error: \(error)")
               }
            }
         }
      }
   }
   
   func updateCellSize() {
      
      if let layout = collectionView.collectionViewLayout as? CollectionViewLayout {
         
         //layout.resetLayout()
         
         collectionView.reloadData()
      }
   }
}

extension ViewController: UICollectionViewDelegate {
   
   func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
      
      
   }
}

extension ViewController: UICollectionViewDataSource {
   
   func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
      return images.count
   }
   
   func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      
      guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(CollectionViewCell), forIndexPath: indexPath) as? CollectionViewCell else {
         
         fatalError()
      }
      //cell.bind(withPresenter: items[indexPath.row]) {
         //self.updateCellSize()
      //}
      
      guard let ig = images[indexPath.row] else {
         fatalError()
      }
      
      cell.image = ig
      
      return cell
   }
}

extension ViewController: CollectionViewLayouttable {
   
   func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
      
//
//      guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CollectionViewCell, image = cell.image else {
//         
//         return 80
//      }
   let image = images[indexPath.row]
      let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
      let rect = AVMakeRectWithAspectRatioInsideRect(image!.size, boundingRect)
      return rect.size.height
   }
}



