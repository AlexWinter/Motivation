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
    var tapGestureRecognizer : UITapGestureRecognizer!
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?

    @IBOutlet weak var navBarTitle: UINavigationItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var bodyTextview: UITextView!
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
            shareButton.isEnabled = false
        }

        bodyTextview.delegate = self
        bodyTextview.tintColor = Constants.myColor.fullAlpha
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        swipe.direction = .down
        bodyTextview.addGestureRecognizer(swipe)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShown(n:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShown(n:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.navBarTapped(_:)))
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationItem.largeTitleDisplayMode = .always
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.removeGestureRecognizer(tapGestureRecognizer)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func navBarTapped(_ theObject: AnyObject){
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
        selectedSlogan = Slogan(headline: navBarTitle.title!, text: bodyTextview.text, fireDay: Date().calculateFireDate(daysAdding: 0))
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
            UIApplication.shared.keyWindow?.tintColor = Constants.myColor.fullAlpha
            
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
        if bodyTextview.text == "" {
            bodyTextview.text = "Text hier eingeben"
        }
        return true
    }

//    @objc func keyboardShown(n:NSNotification) {
//        let d = n.userInfo!
//        var r = (d[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        r = self.bodyTextview.convert(r, from:nil)
//        self.bodyTextview.contentInset.bottom = r.size.height
//        self.bodyTextview.scrollIndicatorInsets.bottom = r.size.height
//    }

    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }

            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)


            var r = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            r = self.bodyTextview.convert(r, from:nil)
            self.bodyTextview.contentInset.bottom = r.size.height
            self.bodyTextview.scrollIndicatorInsets.bottom = r.size.height
        }
    }

    @objc func changeTitle() {
        let alertController = UIAlertController(title: "Neue Überschrift", message: "Geben Sie eine neue Überschrift ein.", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Speichern", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                if !(field.text?.isEmpty)! {
                    self.navBarTitle.title = field.text
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
        alertController.view.tintColor = Constants.myColor.fullAlpha

        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        bodyTextview.resignFirstResponder()
    }
}
