//
//  QuoteTableViewCell.swift
//  Quotes
//
//  Created by Robert Berry on 2/28/18.
//  Copyright © 2018 Robert Berry. All rights reserved.
//

import UIKit

class QuoteTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    static let reuseIdentifier = "QuoteCell"
    
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var contentsLabel: UILabel!
    
    // MARK: Initialization 

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
