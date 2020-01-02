//
//  TrainChooseViewController.swift
//  MyRouteTransit
//
//  Created by Kentaro on 2020/01/03.
//  Copyright © 2020 Kentaro. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import CalculateCalendarLogic

class TrainChooseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var railway:RailwayLine!
    var station:Station!
    var railDirection:RailDirection!
    var stationTrainList = [Train]()
    var otherStations = [Station]()
    
    var trainTypeList = [TrainType]()
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var trainView: UITableView!
    
    let calendarJudge = CalculateCalendarLogic()
    let config = Configuration()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let date = Date()
        self.timePicker.setDate(date, animated: false)
        let calendar = Calendar.current
        
        var calendarString = ""
        if calendarJudge.judgeJapaneseHoliday(year: calendar.component(.year, from: date), month: calendar.component(.month, from: date), day: calendar.component(.day, from: date), checkNationalHoliday: true){
            calendarString = "odpt.Calendar:SaturdayHoliday"
        }else{
            calendarString = "odpt.Calendar:Weekday"
        }
        
        self.getTimetableFromOdptApi(calendar: calendarString)
        
        let trainTypeJsonPath = Bundle.main.path(forResource: "trainType", ofType: "json")!
        
        
        let trainTypeJsonObject = JSON(parseJSON: try! String(contentsOfFile: trainTypeJsonPath))
        for trainTypeJson in trainTypeJsonObject{
            let trainType = TrainType()
            trainType.typeCode = trainTypeJson.1["owl:sameAs"].stringValue
            trainType.typeTitle = trainTypeJson.1["odpt:trainTypeTitle"]["ja"].stringValue
            
            self.trainTypeList.append(trainType)
        }
        
        self.trainView.delegate = self
        self.trainView.dataSource = self
    }
    
    func getTimetableFromOdptApi(calendar:String){
        Alamofire.request("\(config["ODPT_BASE_URL"])/api/v4/odpt:StationTimetable?odpt:railway=\(railway.railwayCode)&odpt:station=\(station.stationCode)&odpt:calendar=\(calendar)&odpt:railDirection=\(railDirection.directionCode)&acl:consumerKey=\(config["ODPT_API_KEY"])").responseJSON{response in
            guard let value = response.result.value else{
                return
            }
            
            let timetableJsonObject = JSON(value)
            for trainObject in timetableJsonObject[0]["odpt:stationTimetableObject"]{
                let train = Train()
                train.trainCode = trainObject.1["odpt:train"].stringValue
                train.trainNumber = trainObject.1["odpt:trainNumber"].stringValue
                train.departureTimeTitle = trainObject.1["odpt:departureTime"].stringValue
                train.type = self.trainTypeList.filter({$0.typeCode == trainObject.1["odpt:trainType"].stringValue})[0]
                for stationObject in trainObject.1["odpt:destinationStation"]{
                    if self.station.stationCode == stationObject.1.stringValue{
                        train.destination.append(self.station)
                    }else{
                        train.destination.append(self.otherStations.filter({$0.stationCode == stationObject.1.stringValue})[0])
                    }
                }
                
                var departureTimeArray = [
                    Int(train.departureTimeTitle.split(separator: ":")[0])!,
                    Int(train.departureTimeTitle.split(separator: ":")[1])!
                ]
                
                if departureTimeArray[0] <= 4{
                    departureTimeArray[0] += 24
                }
                
                let selectedDateOnPicker = self.timePicker.date
                let calendar = Calendar.current
                train.departureTime = calendar.date(from: DateComponents.init(timeZone: .current, year: calendar.component(.year, from: selectedDateOnPicker), month: calendar.component(.month, from: selectedDateOnPicker), day: calendar.component(.day, from: selectedDateOnPicker), hour: departureTimeArray[0], minute: departureTimeArray[1]))!
                
                self.stationTrainList.append(train)
            }
            
            self.stationTrainList = self.stationTrainList.filter({$0.departureTime >= self.timePicker.date})
            self.stationTrainList.sort(by: {$1.departureTime < $1.departureTime})
            
            self.trainView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationTrainList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainViewCell") as! TrainViewCell
        let targetTrain = self.stationTrainList[indexPath.row]
        cell.trainTypeText.text = "\(targetTrain.type.typeTitle)|\(targetTrain.trainNumber)"
        
        var destinations = [String]()
        for station in targetTrain.destination{
            if station.stationCode == self.station.stationCode{
                destinations.append(station.stationName)
            }else{
                destinations.append(self.otherStations.filter({$0.stationCode == station.stationCode})[0].stationName)
            }
        }
        
        cell.destinationStationText.text = destinations.joined(separator: ",")
        cell.departureTimeText.text = targetTrain.departureTimeTitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
