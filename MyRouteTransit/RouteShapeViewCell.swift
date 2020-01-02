//
//  RouteShapeViewCell.swift
//  MyRouteTransit
//
//  Created by Kentaro on 2020/01/02.
//  Copyright © 2020 Kentaro. All rights reserved.
//

import UIKit

class RouteShapeViewCell: UITableViewCell {
    
    @IBOutlet weak var originStationLabel: UILabel!
    @IBOutlet weak var destinationStationLabel: UILabel!
    @IBOutlet weak var departureTimeLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var railwayTitleLabel: UILabel!
    @IBOutlet weak var terminalStationNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
