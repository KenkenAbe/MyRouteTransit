//
//  RailwayLineChooseViewController.swift
//  MyRouteTransit
//
//  Created by Kentaro on 2020/01/02.
//  Copyright © 2020 Kentaro. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON

class RailwayLineChooseViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    var availableOperators = [TransportOperator]()
    var availableRailways = [String:[RailwayLine]]()
    var availableStations = [String:[Station]]()
    
    @IBOutlet weak var railwayView: UITableView!
    
    let config = Configuration()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        if availableOperators.count == 0{
            return
        }
        
        for o in self.availableOperators{
            self.availableRailways[o.operatorCode] = [RailwayLine]()
        }
        
        var operatorCodeList = [String]()
        availableOperators.forEach({operatorCodeList.append($0.operatorCode)})
        
        let path = Bundle.main.path(forResource: "railways", ofType: "json")!
        let railwayObjectJsonString = try! String(contentsOfFile: path)
    
        let railwayLineJsonObject = JSON(parseJSON: railwayObjectJsonString)
        print(railwayLineJsonObject)
        for o in self.availableOperators{
            for railway in railwayLineJsonObject.filter({$0.1["odpt:operator"].stringValue == o.operatorCode}){
                let railwayObject = RailwayLine()
                railwayObject.railwayOperator = o
                railwayObject.railwayCode = railway.1["owl:sameAs"].stringValue
                railwayObject.railwayName = railway.1["odpt:railwayTitle"]["ja"].stringValue
                
                self.availableStations[railwayObject.railwayCode] = [Station]()
                
                let stations = railway.1["odpt:stationOrder"]
                for station in stations{
                    let stationObject = Station()
                    stationObject.railwayOperator = o
                    stationObject.railwayLine = railwayObject
                    stationObject.stationIndex = station.1["odpt:index"].intValue
                    stationObject.stationCode = station.1["odpt:station"].stringValue
                    stationObject.stationName = station.1["odpt:stationTitle"]["ja"].stringValue
                    
                    self.availableStations[railwayObject.railwayCode]?.append(stationObject)
                }
                
                let railDirectionJsonFilePath = Bundle.main.path(forResource: "railDirections", ofType: "json")!
                let railDirectionJsonObject = JSON(parseJSON: try! String(contentsOfFile: railDirectionJsonFilePath))
                
                if let railDirectionString = railway.1["odpt:ascendingRailDirection"].string{
                    let railDirectionObject = RailDirection()
                    railDirectionObject.directionCode = railDirectionString
                    railDirectionObject.directionTitle = railDirectionJsonObject.filter({$0.1["owl:sameAs"].stringValue == railDirectionString})[0].1["odpt:railDirectionTitle"]["ja"].stringValue
                    
                    railwayObject.availableDirections.append(railDirectionObject)
                }
                if let railDirectionString = railway.1["odpt:descendingRailDirection"].string{
                    let railDirectionObject = RailDirection()
                    railDirectionObject.directionCode = railDirectionString
                    railDirectionObject.directionTitle = railDirectionJsonObject.filter({$0.1["owl:sameAs"].stringValue == railDirectionString})[0].1["odpt:railDirectionTitle"]["ja"].stringValue
                    
                    railwayObject.availableDirections.append(railDirectionObject)
                }
                
                if railwayObject.availableDirections.count != 0{
                    self.availableRailways[o.operatorCode]?.append(railwayObject)
                }
            }
        }
        
        availableOperators = availableOperators.filter({availableRailways[$0.operatorCode]!.filter({$0.availableDirections.count != 0}).count != 0})
        
        railwayView.delegate = self
        railwayView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //事業者数を返す
        return availableOperators.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //事業者名を返す
        return availableOperators[section].operatorName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let railways = availableRailways[availableOperators[section].operatorCode]{
            //該当セクションの事業者に紐づく路線を返す
            return railways.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let railways = availableRailways[availableOperators[indexPath.section].operatorCode] else{
            fatalError()
        }
        
        let cell = UITableViewCell()
        cell.textLabel?.text = railways[indexPath.row].railwayName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRailway = availableRailways[availableOperators[indexPath.section].operatorCode]![indexPath.row]
        
        let nextView = storyboard!.instantiateViewController(identifier: "StationChooseView") as! StationChooseViewController
        nextView.railway = selectedRailway
        nextView.stations = self.availableStations[selectedRailway.railwayCode]!
        nextView.railwayDirection = selectedRailway.availableDirections
        nextView.modalTransitionStyle = .flipHorizontal
        self.present(nextView, animated: true, completion: nil)
    }
}
