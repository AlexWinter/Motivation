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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UIViewControllerPreviewingDelegate {

    var data = [Slogan]()
    var filteredSlogans = [Slogan]()

    var notifier : NotificationManager {
        return (UIApplication.shared.delegate! as! AppDelegate).notificationManager
    }
    var deletedSlogan: Slogan!
    var deletedLine = 0
    var selectedRow = 0
    var closestSlogan: String = ""
    let searchController = UISearchController(searchResultsController: nil)

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

        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.6
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)

        NotificationCenter.default.addObserver(self, selector: #selector(self.openSpecificVC(_:)), name: .openFromNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recalculateRandomDays), name: .recalculateRandomDays , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openFromTodayWidget), name: .openFromWidget, object: nil)

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.becomeFirstResponder()

        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Suchen"
        searchController.searchBar.backgroundColor = .clear
        searchController.searchBar.barTintColor = Constants.myColor.fullAlpha
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barStyle = .default
        searchController.searchBar.isTranslucent = true
        definesPresentationContext = true

        navigationItem.searchController = searchController
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = UIColor.white
                backgroundview.layer.cornerRadius = 10
                backgroundview.clipsToBounds = true
            }
        }

        let textFieldInsideUISearchBar = searchController.searchBar.value(forKey: "searchField") as! UITextField
        let tempFontSize = textFieldInsideUISearchBar.font?.pointSize
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.font.rawValue: UIFont(name: "Avenir Next", size: tempFontSize!)!, NSAttributedStringKey.foregroundColor.rawValue: Constants.myColor.fullAlpha]
        UITextField.appearance(whenContainedInInstancesOf: [type(of: searchController.searchBar)]).tintColor = Constants.myColor.fullAlpha

        if (data.count == 0) {
            alertNoData()
        }

        notifier.pendingNotifications { [weak self] in
            print("\(String(describing: self?.notifier.allPendingNotifications))")
            if (self?.notifier.allPendingNotifications == 0) {
                // show Alert for new Notifications
                self?.alertNoMoreFutureNotificationsScheduled()
            }
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.headlineInNotification != "" {
            openFromNotification(notificationHeadline: appDelegate.headlineInNotification)
            appDelegate.headlineInNotification = ""
        } else if textInWidget != "" {
            openFromTodayWidget()
            textInWidget = ""
        }        
//        notifier.testLocalNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.reloadData()
        getClosestSlogan()
    }

    func getClosestSlogan() {
        if (data.count == 0) {
            closestSlogan = ""
            return
        }
        let now = Date()
        var distance: Double = 48 * 60 * 60
        var temp: Double = 0

        for headline in data {
            temp = now.timeIntervalSince(headline.fireDay)
            if (temp > 0 && temp < distance) {
                distance = temp
                closestSlogan = headline.headline
            }
        }
    }

    @objc func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            tableView.setEditing(true, animated: true)
        }
    }

    // MARK: Shake Gesture
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }

    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if deletedSlogan == nil {
                // Nothing to restore
                displayAlertNothingToUndo()
            } else {
                // Restore last deleted Slogan
                displayAlertForUndoLastDelete()
            }
        }
    }

    // MARK: Undelete or restore
    func displayAlertNothingToUndo() {
        let alertController = UIAlertController(title: "", message: "Kein gelöschter Spruch zum Wiederherstellen gefunden.", preferredStyle: UIAlertControllerStyle.alert)

        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
        }

        alertController.addAction(okAction)
        alertController.view.tintColor = Constants.myColor.fullAlpha

        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayAlertForUndoLastDelete() {
        let alertController = UIAlertController(title: "Wiederherstellen?", message: "Sollen der zuletzt gelöscht Spruch \"\(deletedSlogan.headline)\" wiederhergestellt werden?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ja", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.undoDelete()
        }
        let cancelAction = UIAlertAction(title: "Nein", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = Constants.myColor.fullAlpha

        self.present(alertController, animated: true, completion: nil)
    }
    
    func undoDelete() {
        if deletedLine == 0 {
            data.append(deletedSlogan)
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: data.count - 1, section: 0)], with: .left)
            tableView.endUpdates()
            
            recalculateRandomDays()
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: data.count - 1, section: 0), at: .middle, animated: true)
        } else {
            data.insert(deletedSlogan, at: deletedLine)
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: deletedLine, section: 0)], with: .fade)
            tableView.endUpdates()

            recalculateRandomDays()
            tableView.scrollToRow(at: IndexPath(row: deletedLine, section: 0), at: .middle, animated: true)
        }
        deletedSlogan = nil
        deletedLine = 0
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
                let entry: Slogan
                if let destination = segue.destination as? DetailViewController,
                    let indexPath = tableView.indexPathForSelectedRow {
                    if isFiltering() {
                        entry = filteredSlogans[indexPath.row]
                        destination.selectedSlogan = entry
                    } else {
                        entry = data[indexPath.row]
                        destination.selectedSlogan = entry
                    }
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
                recalculateRandomDays()
            } else {
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
        if isFiltering() {
            return filteredSlogans.count
        }
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath)
        let entry: Slogan
        if isFiltering() {
            entry = filteredSlogans[indexPath.row]
        } else {
            entry = data[indexPath.row]
        }
        
//        cell.textLabel?.text = entry.headline
        cell.textLabel?.attributedText = NSMutableAttributedString(string: entry.headline, attributes: [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont(name: "Avenir Next", size: (cell.textLabel?.font.pointSize)!)!])
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.textLabel?.textColor = Constants.myColor.fullAlpha

    // MARK: Highlight last Slogan
        if (HighlightLastSlogan.isOn && entry.headline == closestSlogan) {
            cell.contentView.superview!.backgroundColor = Constants.myColor.halfAlpha
            cell.textLabel?.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = UIColor.white
        } else {
            cell.contentView.superview!.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = Constants.myColor.fullAlpha
        }
        
//        if (selectedRow != 0 && indexPath.row == selectedRow) {
//            cell.backgroundColor = UIColor.red
////            tableView.deselectRow(at: IndexPath(row: selectedRow, section: 0) , animated: true)
//            print("drin?")
//        }
        return cell
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        selectedRow = indexPath.row
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

        cell?.contentView.superview!.backgroundColor = UIColor.clear
        cell?.contentView.backgroundColor = UIColor.clear
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.textColor = Constants.myColor.fullAlpha

        if (cell?.textLabel?.text == closestSlogan) {
            cell?.contentView.backgroundColor = UIColor.clear
            cell?.backgroundColor = UIColor.clear
            cell?.textLabel?.textColor = UIColor.white
            cell?.textLabel?.backgroundColor = UIColor.white
            cell?.contentView.superview!.backgroundColor = Constants.myColor.halfAlpha
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if data.count == 1 {
                data.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                data = []
                saveData()
                recalculateRandomDays()
                scheduleAllNotifications()
                alertNoData()
            } else {
                deletedSlogan = data[indexPath.row]
                deletedLine = indexPath.row
                data.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                recalculateRandomDays()
            }
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
    
    func openFromNotification(notificationHeadline: String) {
        for headline in data {
            if headline.headline == notificationHeadline {
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

    @objc func openFromTodayWidget() {
        for entry in data {
            if entry.text == textInWidget {
                let index = data.index(where: { (item) -> Bool in
                    item.headline == entry.headline
                })

                let rowToSelect = IndexPath(row: index!, section: 0)
                let cell = tableView.cellForRow(at: rowToSelect)
                tableView.selectRow(at: rowToSelect, animated: true, scrollPosition: .top)
                performSegue(withIdentifier: "ShowSlogan", sender: cell)
            }
        }
    }

    func notificationsAlreadyScheduled() -> Bool {
        let defaults = UserDefaults.standard
        let alreadyScheduled = defaults.bool(forKey: UserDefaults.Keys.NotificationsAlreadyScheduled)
        if !alreadyScheduled {
            defaults.set(true, forKey: UserDefaults.Keys.NotificationsAlreadyScheduled)
            return false
        } else {
            return true
        }
    }
    
    @objc func recalculateRandomDays() {
        if (data.count == 0) { return }
        let unshuffledArray = Array(1 ... data.count)
        let shuffledArray = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: unshuffledArray)
        var i = 0

        for saying in data {
            saying.fireDay = Date().calculateFireDate(daysAdding: shuffledArray[i] as! Int)
            i += 1
        }

        saveData()
        scheduleAllNotifications()
        getClosestSlogan()
    }

    func scheduleAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        if (data.count != 0) {
            data.forEach { (saying ) in
                notifier.scheduleNotification(with: saying.headline, text: saying.text, date: saying.fireDay)
            }
        }
    
        notifier.pendingNotifications { [weak self] in
            print("\(String(describing: self?.notifier.allPendingNotifications))")
        }
//        notifier.scheduleNoMoreFutureNotificationsReminder()
    }

    //MARK: Load / save Data
    func loadData() -> [Slogan]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Slogan.ArchiveURL.path) as? [Slogan]
    }

    func saveData() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(data, toFile: Slogan.ArchiveURL.path)
        if isSuccessfulSave {
            saveDataForWidget()
//            print("Data successfully saved")
        } else {
//            print("Failed to save data...")
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

        var times: [Date] = []
        
        for slogan in self.data {
            times.append(slogan.fireDay)
        }
        
        let defaults2 = UserDefaults(suiteName: "group.com.alexwinter.motivation")
        let data3 = NSKeyedArchiver.archivedData(withRootObject: times)
        defaults2?.setValue(data3, forKey: "widgetTimes")
    }

    func alertNoData() {
        let alertController = UIAlertController(title: "Keine Daten vorhanden", message: "Sollen die Standard Sprüche geladen werden?", preferredStyle: .alert)
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
        alertController.view.tintColor = Constants.myColor.fullAlpha

        self.present(alertController, animated: true, completion: nil)
    }
    
    func alertNoMoreFutureNotificationsScheduled() {
        let alertController = UIAlertController(title: "Keine Benachrichtigungen mehr geplant", message: "Es sind keine Benachrichtigungen mehr für die Zukunft geplant. Sollen alle Sprüche neu eingeplant werden?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ja", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.recalculateRandomDays()
        }
        let cancelAction = UIAlertAction(title: "Nein", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = Constants.myColor.fullAlpha
        
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

// MARK: Peek & Pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return nil }
        detailViewController.preferredContentSize = CGSize(width: 0, height: 360)
        detailViewController.selectedSlogan = data[indexPath.row]
        return detailViewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
// MARK: - Filtering / Searching
    func filterContentForSearchText(_ searchText: String) {
        filteredSlogans = data.filter({( slogan : Slogan) -> Bool in
//            let doesCategoryMatch = true
            
            if searchBarIsEmpty() {
                return false
            } else {
//                return doesCategoryMatch && slogan.headline.lowercased().contains(searchText.lowercased()) || slogan.text.lowercased().contains(searchText.lowercased())
                return slogan.headline.lowercased().contains(searchText.lowercased()) || slogan.text.lowercased().contains(searchText.lowercased())
            }
        })
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}

extension ViewController: UISearchBarDelegate {
// MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}

extension ViewController: UISearchResultsUpdating {
// MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
