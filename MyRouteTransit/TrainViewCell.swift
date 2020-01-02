//
//  TrainViewCell.swift
//  MyRouteTransit
//
//  Created by Kentaro on 2020/01/03.
//  Copyright © 2020 Kentaro. All rights reserved.
//

import UIKit

class TrainViewCell: UITableViewCell {

    @IBOutlet weak var trainTypeText: UILabel!
    @IBOutlet weak var departureTimeText: UILabel!
    @IBOutlet weak var destinationStationText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
