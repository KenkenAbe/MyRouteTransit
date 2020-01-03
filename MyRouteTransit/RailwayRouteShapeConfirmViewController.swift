//
//  RailwayRouteShapeConfirmViewController.swift
//  MyRouteTransit
//
//  Created by Kentaro on 2020/01/01.
//  Copyright © 2020 Kentaro. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON

class RailwayRouteShapeConfirm: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var routeShape = [RouteShapeBase]()
    @IBOutlet weak var summaryView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        summaryView.delegate = self
        summaryView.dataSource = self
        summaryView.rowHeight = UITableView.automaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.routeShape.count == 0{
            return 1
        }else{
            return self.routeShape.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == routeShape.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RouteShapeUtility")!
            return cell
            
        }else{
            let targetRouteShape = routeShape[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RouteShapeView") as! RouteShapeViewCell
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.locale = Locale.current
            
            cell.departureTimeLabel.text = "\(formatter.string(from: targetRouteShape.originStationDepartureTime))発"
            cell.arrivalTimeLabel.text = "\(formatter.string(from: targetRouteShape.destinationStationArrivalTime))着"
            
            cell.originStationLabel.text = targetRouteShape.originStationCode.stationName
            cell.destinationStationLabel.text = targetRouteShape.destinationStationCode.stationName
            
            cell.railwayTitleLabel.text = "\(targetRouteShape.railwayCode.railwayOperator.operatorName) \(targetRouteShape.railwayCode.railwayName)"
            
            var terminalStations = [String]()
            for terminalStation in targetRouteShape.train.destination{
                terminalStations.append(terminalStation.stationName)
            }
            cell.terminalStationNameLabel.text = "\(terminalStations.joined(separator: ","))行"
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == routeShape.count{
            return 43.5
        }else{
            return 200.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == routeShape.count{
            let nextView = storyboard!.instantiateViewController(identifier: "railwayChooseView") as! RailwayLineChooseViewController
            let db = try! Realm()
            let operatorDbData = db.objects(TransportOperator.self)
            for operatorRow in operatorDbData{
                nextView.availableOperators.append(operatorRow)
            }
            
            self.present(nextView, animated: true, completion: nil)
        }else{
            tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        }
    }
}
