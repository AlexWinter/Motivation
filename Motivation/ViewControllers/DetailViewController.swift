//
//  detailViewController.swift
//  Motivation
//
//  Created by Alex Winter on 22.08.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {

    var selectedSlogan: Slogan!
    
    @IBOutlet weak var navBarTitle: UINavigationItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var bodyTextview: UITextView!
    @IBOutlet weak var navBarTitleButton: UIButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedSlogan != nil {
            navBarTitle.title = selectedSlogan.headline
            bodyTextview.text = selectedSlogan.text
            navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
            shareButton.isEnabled = true
        } else {
            navBarTitleButton.setTitle("Überschrift", for: .normal)
            navBarTitle.title = "Überschrift"
            shareButton.isEnabled = false
        }

        bodyTextview.delegate = self
        bodyTextview.tintColor = Constants.myColor.fullAlpha
        navBarTitleButton.setTitle(navBarTitle.title , for: .normal)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        swipe.direction = .down
        bodyTextview.addGestureRecognizer(swipe)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShown(n:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }

    @IBAction func navBarTouch(_ sender: UIButton) {
        changeTitle()
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            print("The save button was not pressed, cancelling")
            return
        }
        // Set the Slogan to be passed to ViewController after the unwind segue.
        selectedSlogan = Slogan(headline: navBarTitle.title!, text: bodyTextview.text, fireDay: calculateFireDate(daysAdding: 0))
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (bodyTextview.text == "Text hier eingeben" || bodyTextview.text.isEmpty || navBarTitle.title == "Überschrift") {
            if navBarTitle.title == "Überschrift" {
                changeTitle()
            } else if bodyTextview.text == "Text hier eingeben" {
                bodyTextview.becomeFirstResponder()
            }
            return false
        }
        return true
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddingMode = presentingViewController is UINavigationController

        if isPresentingInAddingMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The ViewController is not inside a navigation controller.")
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        if (bodyTextview.text == "Text hier eingeben" || bodyTextview.text.isEmpty || navBarTitle.title == "Überschrift") {
            return
        } else {
            let text: String = String(navBarTitle.title! + ":\n\"" + bodyTextview.text + "\"")
            let activityViewController = UIActivityViewController(activityItems: [text as Any], applicationActivities: nil)

            activityViewController.popoverPresentationController?.barButtonItem = (sender as! UIBarButtonItem)

            activityViewController.excludedActivityTypes = [
                UIActivityType.postToWeibo,
                UIActivityType.postToTencentWeibo,
                UIActivityType.assignToContact,
                UIActivityType.saveToCameraRoll,
                UIActivityType.addToReadingList,
                UIActivityType.postToFlickr,
                UIActivityType.postToVimeo,
                UIActivityType.airDrop,
                UIActivityType.print
            ]
            self.present(activityViewController, animated: true, completion: nil)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bodyTextview.setContentOffset(CGPoint.zero, animated: false)
    }
    
//    MARK: TextView
    func textViewDidBeginEditing(_ textView: UITextView) {
        if bodyTextview.text == "Text hier eingeben" {
            bodyTextview.text = ""
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        // Hide the keyboard
        textView.resignFirstResponder()
        if self.navBarTitle.title != "Überschrift" {
            shareButton.isEnabled = true
        }
        return true
    }

    @objc func keyboardShown(n:NSNotification) {
        let d = n.userInfo!
        var r = (d[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        r = self.bodyTextview.convert(r, from:nil)
        self.bodyTextview.contentInset.bottom = r.size.height
        self.bodyTextview.scrollIndicatorInsets.bottom = r.size.height
    }

    @objc func changeTitle() {
        let alertController = UIAlertController(title: "Neue Überschrift", message: "Geben Sie eine neue Überschrift ein.", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Speichern", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                if !(field.text?.isEmpty)! {
                    self.navBarTitle.title = field.text
                    self.navBarTitleButton.setTitle(field.text, for: .normal)
                    self.shareButton.isEnabled = true
                }
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "Überschrift"
            textField.autocapitalizationType = .sentences

            if self.navBarTitle.title != "Überschrift" {
                textField.text = self.navBarTitle.title
            }
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        bodyTextview.resignFirstResponder()
    }
}
