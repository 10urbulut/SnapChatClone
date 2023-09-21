//
//  SnapVC.swift
//  SnapChatClone
//
//  Created by Onur Bulut on 20.09.2023.
//

import UIKit
import ImageSlideshow
import Kingfisher

class SnapVC: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    
    var selectedSnap : Snap?
    var inputArray = [KingfisherSource]()
    override func viewDidLoad() {
        super.viewDidLoad()
     
   
        if let snap = selectedSnap{
            timeLabel.text = "Time Difference: \(snap.timeDifference)"
            for imageUrl in snap.imageUrlArray{
                inputArray.append(KingfisherSource(urlString: imageUrl)!)
            }
            
            let imageSlideShow = ImageSlideshow(frame: CGRect(x: 10, y: 10, width: self.view.frame.width * 0.95, height: self.view.frame.height * 0.95))
          
            let pageIndicator = UIPageControl()
            pageIndicator.currentPageIndicatorTintColor = .lightGray
            pageIndicator.pageIndicatorTintColor = .black
            imageSlideShow.pageIndicator = pageIndicator
            
            imageSlideShow.backgroundColor = .white
            imageSlideShow.contentScaleMode = .scaleAspectFit
            imageSlideShow.setImageInputs(inputArray)
            self.view.addSubview(imageSlideShow)
            self.view.bringSubviewToFront(timeLabel)
        }
        
        
    }
    
    

 

}
