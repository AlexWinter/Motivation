//
//  SettingsViewController.swift
//  Motivation
//
//  Created by Alex Winter on 26.09.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications
import MessageUI

class SettingsViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UNUserNotificationCenterDelegate, MFMailComposeViewControllerDelegate {

    var notifier : NotificationManager {
        return (UIApplication.shared.delegate! as! AppDelegate).notificationManager
    }

    private var startTimeCellEpanded: Bool = false
    private var endTimeCellEpanded: Bool = false
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)

    @IBOutlet weak var cellSoundIndividual: UITableViewCell!
    @IBOutlet weak var cellSoundStandard: UITableViewCell!
    @IBOutlet weak var pickerStartTime: UIDatePicker!
    @IBOutlet weak var pickerEndTime: UIDatePicker!
    @IBOutlet weak var labelStartTime: UILabel!
    @IBOutlet weak var labelEndTime: UILabel!
    @IBOutlet weak var highlightSwitch: UISwitch!
    @IBOutlet weak var labelStandardSound: UILabel!
    @IBOutlet weak var labelIndividualSound: UILabel!
    @IBOutlet weak var labelStart: UILabel!
    @IBOutlet weak var labelEnd: UILabel!
    @IBOutlet weak var labelResetData: UILabel!
    @IBOutlet weak var labelRecalculateNotifications: UILabel!
    @IBOutlet weak var labelHighlightLastSlogan: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelTipps: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSavedSound()
        getSavedTimeFrame()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragViewDown(_:)))
        navigationController!.view.addGestureRecognizer(panGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        changeAllTextColors()
        highlightSwitch.isOn = HighlightLastSlogan.isOn
    }

    @IBAction func dragViewDown(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        
        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            if (touchPoint.y - initialTouchPoint.y > 0) && (touchPoint.y - initialTouchPoint.y < 100) {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - self.initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }

    func changeAllTextColors() {
//        labelIndividualSound.textColor = Constants.myColor.fullAlpha
//        labelStandardSound.textColor = Constants.myColor.fullAlpha
//        labelStart.textColor = Constants.myColor.fullAlpha
//        labelEnd.textColor = Constants.myColor.fullAlpha
//        labelStartTime.textColor = Constants.myColor.fullAlpha
//        labelEndTime.textColor = Constants.myColor.fullAlpha
//        labelResetData.textColor = Constants.myColor.fullAlpha
//        labelEmail.textColor = Constants.myColor.fullAlpha
//        labelHighlightLastSlogan.textColor = Constants.myColor.fullAlpha
//        labelRecalculateNotifications.textColor = Constants.myColor.fullAlpha
//        labelTipps.textColor = Constants.myColor.fullAlpha
        pickerStartTime.setValue(Constants.myColor.fullAlpha, forKeyPath: "textColor")
        pickerEndTime.setValue(Constants.myColor.fullAlpha, forKeyPath: "textColor")
        
        labelIndividualSound.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 16)!)
        labelStandardSound.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 16)!)
        labelStart.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 16)!)
        labelEnd.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 16)!)
        labelStartTime.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 16)!)
        labelEndTime.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 16)!)
        labelResetData.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 16)!)
        labelEmail.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 16)!)
        labelHighlightLastSlogan.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 16)!)
        labelRecalculateNotifications.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 16)!)
        labelTipps.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 16)!)
        labelHighlightLastSlogan.adjustsFontForContentSizeCategory = true
    }

    func getSavedSound() {
        if NotificationSound.individual {
            cellSoundIndividual.accessoryType = .checkmark
        } else {
            cellSoundStandard.accessoryType = .checkmark
        }
    }

    func getSavedTimeFrame() {
        pickerStartTime.date = TimeFrame.start
        pickerEndTime.date = TimeFrame.end
        updateTimeLabel(label: labelStartTime, from: pickerStartTime)
        updateTimeLabel(label: labelEndTime, from: pickerEndTime)
    }

    @IBAction func highlightLastSloganSwitch(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        if (sender.isOn) {
            HighlightLastSlogan.isOn = true
            defaults.set(true, forKey: UserDefaults.Keys.HighlightLastSloganKey)
        } else {
            HighlightLastSlogan.isOn = false
            defaults.set(false, forKey: UserDefaults.Keys.HighlightLastSloganKey)
        }
    }

    // MARK: TableView
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.textLabel?.attributedText = NSMutableAttributedString(string: (cell?.textLabel?.text)!, attributes: [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont(name: "Avenir Next", size: (cell?.textLabel?.font.pointSize)!)!])
        cell?.textLabel?.adjustsFontForContentSizeCategory = true
        
        if (indexPath.section == 2 && indexPath.row == 0) {
            cell?.selectionStyle = .none
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath.section == 2 && indexPath.row == 0) {
            return nil
        } else {
            return indexPath
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let defaults = UserDefaults.standard

        // Change Sound
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                playCustomSound()
                if !NotificationSound.individual {
                    //  Change Notification Sound to individual Sound
                    cellSoundIndividual.accessoryType = .checkmark
                    cellSoundStandard.accessoryType = .none
                    NotificationSound.individual = true
                    defaults.set(true, forKey: UserDefaults.Keys.IndividualNotificationSound)
//                    notifier.reScheduleAllNotificationsWithTheNewSound()
                    NotificationCenter.default.post(name: .recalculateRandomDays, object: nil)
                }
            } else if indexPath.row == 1 {
                playStandardSound()
                if NotificationSound.individual {
                    //  Change Notification Sound to standard Sound
                    cellSoundIndividual.accessoryType = .none
                    cellSoundStandard.accessoryType = .checkmark
                    NotificationSound.individual = false
                    defaults.set(false, forKey: UserDefaults.Keys.IndividualNotificationSound)
//                    notifier.reScheduleAllNotificationsWithTheNewSound()
                    NotificationCenter.default.post(name: .recalculateRandomDays, object: nil)
                }
            }

        // Change Time
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if startTimeCellEpanded {
                    startTimeCellEpanded = false
                } else {
                    startTimeCellEpanded = true
                    endTimeCellEpanded = false
                }
            } else if indexPath.row == 1 {
                if endTimeCellEpanded {
                    endTimeCellEpanded = false
                } else {
                    endTimeCellEpanded = true
                    startTimeCellEpanded = false
                }
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 1 {
                showAlertForRescheduleNotifications()
            } else if indexPath.row == 2 {
                showAlertForDataReset()
            } else if indexPath.row == 3 {
                let storyboard = UIStoryboard(name: "Tipps", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                present(vc!, animated: true, completion: nil)
            } else if indexPath.row == 4 {
                sendContactEmail()
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            if startTimeCellEpanded {
                return 235
            } else {
                return UITableViewAutomaticDimension
            }
        } else if indexPath.section == 1 && indexPath.row == 1 {
            if endTimeCellEpanded {
                return 235
            } else {
                return UITableViewAutomaticDimension
            }
        }
//        return 40
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.contentView.backgroundColor = Constants.myColor.halfAlpha
        cell?.backgroundColor = Constants.myColor.halfAlpha
        cell?.textLabel?.textColor = UIColor.white
        
        if (indexPath.section == 1 && indexPath.row == 0) {
            labelStart.textColor = UIColor.white
            labelStartTime.textColor = UIColor.white
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            labelEnd.textColor = UIColor.white
            labelEndTime.textColor = UIColor.white
        } else if (indexPath.section == 2 && indexPath.row == 0) {
            cell?.contentView.backgroundColor = UIColor.white
            cell?.backgroundColor = UIColor.white
            cell?.textLabel?.textColor = Constants.myColor.halfAlpha
        }
    }

    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        cell?.contentView.backgroundColor = UIColor.white
        cell?.backgroundColor = UIColor.white
        cell?.textLabel?.textColor = Constants.myColor.fullAlpha

        if (indexPath.section == 1 && indexPath.row == 0) {
            labelStart.textColor = Constants.myColor.fullAlpha
            labelStartTime.textColor = Constants.myColor.fullAlpha
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            labelEnd.textColor = Constants.myColor.fullAlpha
            labelEndTime.textColor = Constants.myColor.fullAlpha
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 {
            switch (notifier.allPendingNotifications) {
            case Int.min..<1: return "Keine offenen Benachrichtigungen"
            case 1: return "Noch 1 offene Benachrichtigung"
            default: return String("Noch " + String(notifier.allPendingNotifications) + " offene Benachrichtigungen")
            }
        }
        return ""
    }

    func sendContactEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["Motivations.App@icloud.com"])
            mail.setMessageBody("", isHTML: true)
            mail.view.tintColor = Constants.myColor.fullAlpha
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    //    MARK: Play Sound
    func playCustomSound() {
        let filename = "DiDiDiDiDi"
        let ext = "m4a"
        
        if let soundUrl = Bundle.main.url(forResource: filename, withExtension: ext) {
            var soundId: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
            AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
                AudioServicesDisposeSystemSoundID(soundId)
            }, nil)
            AudioServicesPlaySystemSound(soundId)
        }
    }

    func playStandardSound() {
        AudioServicesPlaySystemSound(1315)
    }

    //    MARK: PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    @IBAction func startTimeChanged(_ sender: Any) {
        if (pickerStartTime.date >= pickerEndTime.date) {
            pickerEndTime.date = pickerStartTime.date.addingTimeInterval(300)
            updateTimeLabel(label: labelEndTime, from: pickerEndTime)
        }

        updateTimeLabel(label: labelStartTime, from: pickerStartTime)
        setNewTimeFrame()
    }

    @IBAction func endTimeChanged(_ sender: Any) {
        if (pickerEndTime.date <= pickerStartTime.date) {
            pickerStartTime.date = pickerEndTime.date.addingTimeInterval(-300)
            updateTimeLabel(label: labelStartTime, from: pickerStartTime)
        }

        updateTimeLabel(label: labelEndTime, from: pickerEndTime)
        setNewTimeFrame()
    }
    
    func setNewTimeFrame() {
        TimeFrame.start = pickerStartTime.date
        TimeFrame.end = pickerEndTime.date
        UserDefaults.standard.set(pickerStartTime.date, forKey: UserDefaults.Keys.StartTime)
        UserDefaults.standard.set(pickerEndTime.date, forKey: UserDefaults.Keys.EndTime)
        NotificationCenter.default.post(name: .recalculateRandomDays, object: nil)
    }
    
    func updateTimeLabel(label: UILabel, from picker: UIDatePicker) {
        let dateStart = picker.date
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.hour, .minute], from: dateStart)
        label.text = String(format: "%01d", dateComponents.hour!) + ":" + String(format: "%02d", dateComponents.minute!)
    }
    
    func showAlertForDataReset() {
        let alertController = UIAlertController(title: "Sprüche zurücksetzen", message: "Alle bestehenden Sprüche werden gelöscht und die Ursprungssprüche werden geladen.", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Zurücksetzen", style: .default) {
            UIAlertAction in
            NotificationCenter.default.post(name: .reload, object: nil)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) {
            UIAlertAction in
        }
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = Constants.myColor.fullAlpha

        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
        notifier.pendingNotifications { [weak self] in
            print("\(String(describing: self?.notifier.allPendingNotifications))")
        }
    }
    
    func showAlertForRescheduleNotifications() {
        let alertController = UIAlertController(title: "Benachrichtigungen neu planen", message: "Alle bestehenden Benachrichtigungen werden gelöscht und neu eingeplant.", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Neu planen", style: .default) {
            UIAlertAction in
            NotificationCenter.default.post(name: .recalculateRandomDays, object: nil)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) {
            UIAlertAction in
        }
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = Constants.myColor.fullAlpha

        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
        notifier.pendingNotifications { [weak self] in
            print("\(String(describing: self?.notifier.allPendingNotifications))")
        }
    }
}
