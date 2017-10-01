//
//  ViewController.swift
//  Motivation
//
//  Created by Alex Winter on 22.08.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation
import GameKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    var data = [Slogan]()
    let notifier = NotificationManager()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        notifier.requestSendingNotifications()

        if let savedData = loadData() {
            data += savedData
        } else {
            data = Slogan.loadDefaultSlogans()
            self.recalculateRandomDays()
        }

        if !notificationsAlreadyScheduled() {
            self.recalculateRandomDays()
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(ViewController.playSound))
        tapGestureRecognizer.numberOfTapsRequired = 3
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        
        self.becomeFirstResponder()
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.8
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.openSpecificVC(_:)), name: .openFromNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recalculateRandomDays), name: .timeFrameChanged, object: nil)
    }
    
    @objc func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            tableView.setEditing(true, animated: true)
        }
    }
        
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let storyboard = UIStoryboard(name: "Shake", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as UIViewController!
            present(vc!, animated: true, completion: nil)
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if tableView.isEditing {
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            case "NewSlogan":
                if let indexPath = tableView.indexPathForSelectedRow {
                    tableView.deselectRow(at: indexPath , animated: true)
                }
            case "ShowSlogan":
                if let destination = segue.destination as? DetailViewController,
                    let indexPath = tableView.indexPathForSelectedRow {
                    destination.selectedSlogan = data[indexPath.row]
                }
            case "ShowSettings":
                break
            default:
                fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    @IBAction func unwindToList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? DetailViewController, let changedSlogan = sourceViewController.selectedSlogan {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing Slogan
                data[selectedIndexPath.row] = changedSlogan
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                saveData()
            }
            else {
                // Add a new Slogan
                let newIndexPath = IndexPath(row: data.count, section: 0)
                data.append(changedSlogan)
                tableView.insertRows(at: [newIndexPath], with: .bottom)
                tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
                recalculateRandomDays()
            }
        }
    }

    //MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath)
        let entry = data[indexPath.row]
        cell.textLabel?.text = entry.headline
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 16.0)
        cell.textLabel?.textColor = Constants.myColor.fullAlpha
        return cell
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            return
        }
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = Constants.myColor.halfAlpha
        cell?.backgroundColor = Constants.myColor.halfAlpha
        cell?.textLabel?.textColor = UIColor.white
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.clear
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.textColor = Constants.myColor.fullAlpha
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if data.count == 1 {
                data.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                alertNoData()
                return
            }
            // Delete the row from the data source
            data.remove(at: indexPath.row)
            recalculateRandomDays()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }

    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedObject = data[fromIndexPath.row]
        data.remove(at: fromIndexPath.row)
        data.insert(movedObject, at: to.row)
        saveData()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    //MARK: Notifications
    @objc func openSpecificVC (_ notification: NSNotification) {
        if let notificationText = notification.userInfo?["title"] as? String {
            for headline in data {
                if headline.headline == notificationText {
                    let index = data.index(where: { (item) -> Bool in
                        item.headline == headline.headline
                    })
                    
                    let rowToSelect = IndexPath(row: index!, section: 0)
                    let cell = tableView.cellForRow(at: rowToSelect)
                    tableView.selectRow(at: rowToSelect, animated: true, scrollPosition: .top)
                    performSegue(withIdentifier: "ShowSlogan", sender: cell)
                }
            }
        }
    }

    func notificationsAlreadyScheduled() -> Bool {
        let defaults = UserDefaults.standard
        let alreadyScheduled = defaults.bool(forKey: "alreadyScheduled")
        if !alreadyScheduled {
            defaults.set(true, forKey: "alreadyScheduled")
            return false
        } else {
            return true
        }
    }
    
    @objc func recalculateRandomDays() {
        let unshuffledArray = Array(1 ... data.count)
        let shuffledArray = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: unshuffledArray)
        var i = 0

        for saying in data {
            saying.fireDay = calculateFireDate(daysAdding: shuffledArray[i] as! Int)
            i += 1
        }
        saveData()
        scheduleAllNotifications()
    }
    
    func scheduleAllNotifications() -> Void {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        data.forEach { (saying ) in
            notifier.scheduleNotification(with: saying.headline, text: saying.text, date: saying.fireDay)
        }
    }

    //MARK: Load / save Data
    func loadData() -> [Slogan]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Slogan.ArchiveURL.path) as? [Slogan]
    }

    func saveData() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(data, toFile: Slogan.ArchiveURL.path)
        if isSuccessfulSave {
            saveDataForWidget()
            print("Data successfully saved")
        } else {
            print("Failed to save data...")
        }
    }
    
    func saveDataForWidget() {
        var slogans: [String] = []

        for slogan in self.data {
            slogans.append(slogan.text)
        }

        let defaults = UserDefaults(suiteName: "group.com.alexwinter.motivation")
        let data2 = NSKeyedArchiver.archivedData(withRootObject: slogans)
        defaults?.setValue(data2, forKey: "widgetData")
    }

    //MARK: Having fun
    @objc func playSound() {
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
        showFunAlert()
    }
    
    func showFunAlert () {
        let alertController = UIAlertController(title: "😃", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alertNoData() {
        let alertController = UIAlertController(title: "Keine Daten", message: "Sollen die Standard Daten geladen werden?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ja", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.data = Slogan.loadDefaultSlogans()
            self.recalculateRandomDays()
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Nein", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func restoreData() {
        self.data = Slogan.loadDefaultSlogans()
        self.recalculateRandomDays()
    }
    
    @objc func reloadTableData(_ notification: Notification) {
        restoreData()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
