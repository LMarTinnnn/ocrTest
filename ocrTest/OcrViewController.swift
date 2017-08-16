//
//  OcrViewController.swift
//  ocrTest
//
//  Created by 刘勇博 on 16/08/2017.
//  Copyright © 2017 Magicarp. All rights reserved.
//

import UIKit
import TTGSnackbar

class OcrViewController: UIViewController, UITextViewDelegate {
    //model
    var imageToUse: UIImage?
    
    //view
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    //vc
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        indicator.startAnimating()
        createToolbar(textView: textView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.textContainerInset = UIEdgeInsetsMake(20,20, 20, 20);
        setOcr()
        indicator.stopAnimating()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveResult(_ sender: UIButton) {
        UIPasteboard.general.string = textView.text
        // use ttgsnackbar to give an alert for successfully copying
        let alertBar = TTGSnackbar(message: "已复制到粘贴板\n任您处置👄", duration: .middle)
        alertBar.icon = UIImage(named: "完成")
        alertBar.show()
    }
    
    //func
    func setOcr() {
        let wordsArray = OCR().getOcrResult(from: imageToUse!)
        textView.text = wordsArray?.joined(separator: "\n")
    }
    
    
    //auto change the textview frame when keyboard show up and hide
    @objc func updateTextView(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyBoardEndFrameScreenCoordinates =  (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardEndFrame = self.view.convert(keyBoardEndFrameScreenCoordinates, to: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardEndFrame.height, right: 0)
            //textView.scrollIndicatorInsets = textView.contentInset
        }
        
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    //custom keyboard
    func createToolbar(textView : UITextView) {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        let done = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(finishInput))
        toolbar.items = [done]
        toolbar.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        toolbar.tintColor = UIColor.white
        textView.inputAccessoryView = toolbar
    }
    
    @objc func finishInput() {
        textView.endEditing(true)
    }
    
}

func parseWords(ocrArray array: [String]) {
    //
}
