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
    var station:Station!
    var stations = [Station]()
    var otherStations = [Station]()
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
        self.station = self.stations[indexPath.row]
        
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
        let nextView = storyboard!.instantiateViewController(identifier: "TrainChooseView") as! TrainChooseViewController
        nextView.railway = self.railway
        nextView.station = self.station
        nextView.railDirection = direction
        nextView.otherStations = self.otherStations
        
        nextView.modalTransitionStyle = .flipHorizontal
        
        self.present(nextView, animated: true, completion: nil)
    }
}
