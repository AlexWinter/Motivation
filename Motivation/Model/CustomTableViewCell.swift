//
//  CustomTableViewCell.swift
//  Motivation
//
//  Created by Alex Winter on 22.08.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var headline: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
