//
//  SavedRouteShapeCell.swift
//  
//
//  Created by Kentaro on 2019/12/31.
//

import UIKit

class SavedRouteShapeCell: UITableViewCell {

    @IBOutlet weak var timeText: UILabel!
    @IBOutlet weak var idText: UILabel!
    @IBOutlet weak var stationText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
