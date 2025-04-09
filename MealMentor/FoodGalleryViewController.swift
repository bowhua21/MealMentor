//
//  FoodGalleryViewController.swift
//  MealMentor
//
//  Created by Yingting Cao on 4/9/25.
//

import UIKit

class FoodGalleryViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    let imageCount = 5              // number of images
    var current = 0                 // current image
    override func viewDidLoad() {
        super.viewDidLoad()
        showImage(index: 0)

        // Do any additional setup after loading the view.
    }

    @IBAction func onResetButton(_ sender: Any) {
        showImage(index: 0)
        current = 0
    }
    @IBAction func onNextButton(_ sender: Any) {
        current = (current + 1) % imageCount
        showImage(index: current)
        
    }
    @IBAction func onPreviousButton(_ sender: Any) {
        current = (current + imageCount - 1) % imageCount
        showImage(index: current)
    }
    func showImage(index:Int) {
        label.text = "Image \(index)"
        imageView.image = UIImage(named: "image\(index)")
    }
}
