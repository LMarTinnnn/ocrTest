//
//  ShowPhotoViewController.swift
//  ocrTest
//
//  Created by 刘勇博 on 16/08/2017.
//  Copyright © 2017 Magicarp. All rights reserved.
//

import UIKit

class ShowPhotoViewController: UIViewController {
    //model
    var photoToShow: UIImage?

    //view

    @IBOutlet weak var photoShower: UIImageView!
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //vc
    override func viewDidLoad() {
        super.viewDidLoad()
        photoShower.image = photoToShow
        
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ocr" {
            if let ocrVC = segue.destination as? OcrViewController {
                ocrVC.imageToUse = photoToShow
            }
        }
    }
}


