//
//  slogans.swift
//  Motivation
//
//  Created by Alex Winter on 22.08.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import UIKit

let notifier = NotificationManager()

class Slogan: NSObject, NSCoding {

    //MARK: Properties
    var headline: String
    var text: String
    var fireDay: Date

    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("slogans")
    
    //MARK: Types
    struct PropertyKey {
        static let headline = "headline"
        static let text = "text"
        static let fireDay = "fireDay"
    }
    
    //MARK: Initialization
    init?(headline: String, text: String, fireDay: Date) {
        
        // The name must not be empty
        guard !headline.isEmpty else {
            return nil
        }

        guard !text.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.headline = headline
        self.text = text
        self.fireDay = fireDay
        
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(headline, forKey: PropertyKey.headline)
        aCoder.encode(text, forKey: PropertyKey.text)
        aCoder.encode(fireDay, forKey: PropertyKey.fireDay)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let headline = aDecoder.decodeObject(forKey: PropertyKey.headline) as? String else {
            print("Unable to decode the name for a Slogan object.")
            return nil
        }

        let text = aDecoder.decodeObject(forKey: PropertyKey.text) as! String
        let fireDay = aDecoder.decodeObject(forKey: PropertyKey.fireDay) as! Date
    
        // Must call designated initializer.
        self.init(headline: headline, text: text, fireDay: fireDay)
    }
    
    class func loadDefaultSlogans() -> [Slogan] {
        print("loading default slogans")
        var slogans = [Slogan]()
        
        guard let url = Bundle.main.url(forResource: "motivation", withExtension: "json") else {
            return slogans
        }
        do {
            let data = try Data(contentsOf: url)
            guard let rootObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]  else {
                return slogans
            }
            
            guard let sloganObjects = rootObject["slogans"] as? [[String: AnyObject]] else {
                return slogans
            }
            
            for sloganObject in sloganObjects {
                let notifyDate = calculateFireDate(daysAdding: 1)
                
                if let headline = sloganObject["headline"] as? String,
                    let text = sloganObject["text"]  as? String {
                    let slogan = Slogan(headline: headline, text: text, fireDay: notifyDate)
                    slogans.append(slogan!)
                }
            }
        } catch {
            return slogans
        }
        return slogans
    }
}
