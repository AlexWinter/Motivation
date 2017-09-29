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
import LocalAuthentication

class SettingsViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private var startTimeCellEpanded: Bool = false
    private var endTimeCellEpanded: Bool = false
    
    var individualNotificationSound = true
    
    @IBOutlet weak var cellSoundIndividual: UITableViewCell!
    @IBOutlet weak var cellSoundStandard: UITableViewCell!
    @IBOutlet weak var pickerStartTime: UIDatePicker!
    @IBOutlet weak var pickerEndTime: UIDatePicker!
    @IBOutlet weak var labelStartTime: UILabel!
    @IBOutlet weak var labelEndTime: UILabel!

    @IBOutlet weak var labelStandardSound: UILabel!
    @IBOutlet weak var labelIndividualSound: UILabel!
    @IBOutlet weak var labelStart: UILabel!
    @IBOutlet weak var labelEnd: UILabel!
    @IBOutlet weak var labelResetData: UILabel!
    @IBOutlet weak var labelVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSavedSettings()
        getSavedTimeFrame()
        initDatePickers()
        getVersionNumber()
        changeAllTextColors()
        
//        allScheduledNotifications()
    }
//    A small hack because the colors selected in the Storyboard are just not quite there
    func changeAllTextColors() {
        labelIndividualSound.textColor = Constants.myColor.fullAlpha
        labelStandardSound.textColor = Constants.myColor.fullAlpha
        labelStart.textColor = Constants.myColor.fullAlpha
        labelEnd.textColor = Constants.myColor.fullAlpha
        labelStartTime.textColor = Constants.myColor.fullAlpha
        labelEndTime.textColor = Constants.myColor.fullAlpha
        labelResetData.textColor = Constants.myColor.fullAlpha
        labelVersion.textColor = Constants.myColor.fullAlpha
    }
    
    func getSavedSettings() {
        let defaults = UserDefaults.standard

        if (defaults.bool(forKey: "hasLaunchedOnce")) {
            // App already launched
        } else {
            // This is the first launch ever
            defaults.set(true, forKey: "hasLaunchedOnce")
            defaults.set(true, forKey: "individualNotificationSound")
            UserDefaults.standard.set(pickerEndTime.date, forKey: "EndTime")
        }
        
        let individualSound = defaults.bool(forKey: "individualNotificationSound")

        if !individualSound {
            cellSoundStandard.accessoryType = .checkmark
        } else {
            cellSoundIndividual.accessoryType = .checkmark
        }
        individualNotificationSound = individualSound
    }
    
    func getSavedTimeFrame() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if (UserDefaults.standard.object(forKey: "StartTime") != nil) {
            TimeFrame.start = (UserDefaults.standard.object(forKey: "StartTime") as? Date)!
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "HH:mm"
            
            if let date = dateFormatter.date(from: "09:00") {
                pickerStartTime.date = date
                TimeFrame.start = date
            }
        }
        
        if (UserDefaults.standard.object(forKey: "EndTime") != nil) {
            TimeFrame.end = (UserDefaults.standard.object(forKey: "EndTime") as? Date)!
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "HH:mm"
            
            if let date = dateFormatter.date(from: "18:00") {
                pickerEndTime.date = date
                TimeFrame.end = date
            }
        }

        pickerStartTime.date = TimeFrame.start
        pickerEndTime.date = TimeFrame.end
        
        updateTimeLabel(label: labelStartTime, from: pickerStartTime)
        updateTimeLabel(label: labelEndTime, from: pickerEndTime)

    }
    
    func initDatePickers() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        
//        if let date = dateFormatter.date(from: "09:00") {
//            pickerStartTime.date = date
//        }
//        if let date = dateFormatter.date(from: "18:00") {
//            pickerEndTime.date = date
//        }
        
        pickerStartTime.setValue(Constants.myColor.fullAlpha, forKeyPath: "textColor")
        pickerEndTime.setValue(Constants.myColor.fullAlpha, forKeyPath: "textColor")
    }
    
    func getVersionNumber() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.labelVersion.text = "Version: " + version
        }
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.labelVersion.text = self.labelVersion.text! + " Build: " + version
        }
    }
    
//    MARK: TableView
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.textLabel?.font = UIFont(name: "Avenir Next", size: 16.0)
        cell?.textLabel?.textColor = Constants.myColor.fullAlpha
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)
        let defaults = UserDefaults.standard

        // Change Sound
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                playCustomSound()
                cellSoundIndividual.accessoryType = .checkmark
                cellSoundStandard.accessoryType = .none
                defaults.set(true, forKey: "individualNotificationSound")
            } else if indexPath.row == 1 {
                playStandardSound()
                cellSoundIndividual.accessoryType = .none
                cellSoundStandard.accessoryType = .checkmark
                defaults.set(false, forKey: "individualNotificationSound")
            }
        // Change Time
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if startTimeCellEpanded {
                    startTimeCellEpanded = false
                } else {
                    startTimeCellEpanded = true
                }
            } else if indexPath.row == 1 {
                if endTimeCellEpanded {
                    endTimeCellEpanded = false
                } else {
                    endTimeCellEpanded = true
                }
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                showAlertForDataReset()
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            if startTimeCellEpanded {
                return 235
            } else {
                return 42
            }
        } else if indexPath.section == 1 && indexPath.row == 1 {
            if endTimeCellEpanded {
                return 235
            } else {
                return 42
            }
        }
        return 42
    }
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = Constants.myColor.halfAlpha
        cell?.backgroundColor = Constants.myColor.fullAlpha
        cell?.textLabel?.textColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.white
        cell?.backgroundColor = UIColor.white
        cell?.textLabel?.textColor = Constants.myColor.fullAlpha
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
        updateTimeLabel(label: labelStartTime, from: pickerStartTime)
        UserDefaults.standard.set(pickerStartTime.date, forKey: "StartTime")
    }
    
    @IBAction func endTimeChanged(_ sender: Any) {
        updateTimeLabel(label: labelEndTime, from: pickerEndTime)
        UserDefaults.standard.set(pickerEndTime.date, forKey: "EndTime")
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
        }
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) {
            UIAlertAction in
        }
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func allScheduledNotifications() {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default()

        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print("\(request.content.subtitle) mit sound: \(String(describing: request.content.sound?.debugDescription))")
            }
        })
    }
}
