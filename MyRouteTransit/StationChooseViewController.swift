//
//  StationChooseViewController.swift
//  MyRouteTransit
//
//  Created by Kentaro on 2020/01/03.
//  Copyright © 2020 Kentaro. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class StationChooseViewController:UIViewController, UITableViewDelegate, UITableViewDataSource{
    var railway:RailwayLine!
    var stations = [Station]()
    var railwayDirection = [RailDirection]()
    @IBOutlet weak var stationView: UITableView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.stationView.delegate = self
        self.stationView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(railway.railwayOperator.operatorName) \(railway.railwayName)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = stations[indexPath.row].stationName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: "方面を選択してください", preferredStyle: .alert)
        for direction in railwayDirection{
            alert.addAction(UIAlertAction(title: direction.directionTitle, style: .default, handler: {action in
                self.selectDirection(direction: direction)
            }))
        }
        
        self.present(alert, animated: true, completion: nil)
        
        self.stationView.deselectRow(at: indexPath, animated: true)
    }
    
    func selectDirection(direction:RailDirection){
        print(direction.directionTitle)
    }
}
