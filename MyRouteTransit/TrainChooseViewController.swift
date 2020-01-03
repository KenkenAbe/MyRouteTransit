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
    var calendarString = ""
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let date = Date()
        self.timePicker.setDate(date, animated: false)
        let calendar = Calendar.current
        
        calendarString = ""
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
                
                if departureTimeArray[0] <= 3{
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
        let selectedTrain = self.stationTrainList[indexPath.row]
        var trainTimetableJsonObject:JSON!
        var departureTimeList = [TimetableObject]()
        
        let queue = DispatchQueue.global(qos: .utility)
        let semaphore = DispatchSemaphore.init(value: 0)
       

        let selectedDateOnPicker = self.timePicker.date
        var isNotResolveConnectingStationTime = true
        
        let calendar = Calendar.current
        Alamofire.request("\(self.config["ODPT_BASE_URL"])/api/v4/odpt:TrainTimetable?odpt:train=\(selectedTrain.trainCode)&odpt:calendar=\(self.calendarString)&acl:consumerKey=\(self.config["ODPT_API_KEY"])").responseJSON(queue: queue){response in
            guard let value = response.result.value else{
                return
            }

            trainTimetableJsonObject = JSON(value)[0]
            for stationJsonObject in trainTimetableJsonObject["odpt:trainTimetableObject"]{
                let object = TimetableObject()
                object.train = selectedTrain
                
                var arrivalStationCode = ""
                if let s = stationJsonObject.1["odpt:departureStation"].string{
                    arrivalStationCode = s
                }else if let s = stationJsonObject.1["odpt:arrivalStation"].string{
                    arrivalStationCode = s
                }
                
                if self.station.stationCode == arrivalStationCode{
                    object.departureStation = self.station
                }else{
                    object.departureStation = self.otherStations.filter({$0.stationCode == arrivalStationCode})[0]
                }
                
                if let arrivalTime = stationJsonObject.1["odpt:arrivalTime"].string{
                    object.departureTimeTitle = arrivalTime
                }else if let arrivalTime = stationJsonObject.1["odpt:departureTime"].string{
                    object.departureTimeTitle = arrivalTime
                }else{
                    isNotResolveConnectingStationTime = false
                    continue
                }
                
                var departureTimeArray = [
                    Int(object.departureTimeTitle.split(separator: ":")[0])!,
                    Int(object.departureTimeTitle.split(separator: ":")[1])!
                ]
                
                if departureTimeArray[0] <= 3{
                    departureTimeArray[0] += 24
                }
                
                guard let departureTime = calendar.date(from: DateComponents.init(timeZone: .autoupdatingCurrent, year: calendar.component(.year, from: selectedDateOnPicker), month: calendar.component(.month, from: selectedDateOnPicker), day: calendar.component(.day, from: selectedDateOnPicker), hour: departureTimeArray[0], minute: departureTimeArray[1])) else{
                    fatalError()
                }
                
                object.departureTime = departureTime
                departureTimeList.append(object)
            }
            
            semaphore.signal()
        }
        semaphore.wait()
        
        if trainTimetableJsonObject["odpt:nextTrainTimetable"].count != 0{
            //直通先列車の時刻表が利用可能な場合

            let nextTrainGetQueue = DispatchQueue.global(qos: .utility)
            let nextTrainGetSemaphore = DispatchSemaphore.init(value: 0)
            var nextTrainTimeTableJsonObject:JSON!
            Alamofire.request("\(self.config["ODPT_BASE_URL"])/api/v4/odpt:TrainTimetable?owl:sameAs=\(trainTimetableJsonObject["odpt:nextTrainTimetable"][0].stringValue)&acl:consumerKey=\(self.config["ODPT_API_KEY"])").responseJSON(queue: nextTrainGetQueue){response in
                guard let nextTrainTimeTableValue = response.result.value else{
                    return
                }
                
                nextTrainTimeTableJsonObject = JSON(nextTrainTimeTableValue)[0]
                
                nextTrainGetSemaphore.signal()
            }
            nextTrainGetSemaphore.wait()
            
            let nextTrain = Train()
            nextTrain.trainCode = nextTrainTimeTableJsonObject["odpt:train"].stringValue
            nextTrain.trainNumber = nextTrainTimeTableJsonObject["odpt:trainNumber"].stringValue
            nextTrain.departureTime = selectedTrain.departureTime
            nextTrain.departureTimeTitle = selectedTrain.departureTimeTitle
            nextTrain.destination = selectedTrain.destination
            nextTrain.type = self.trainTypeList.filter({$0.typeCode == nextTrainTimeTableJsonObject["odpt:trainType"].stringValue})[0]
            
            for stationJsonObject in nextTrainTimeTableJsonObject["odpt:trainTimetableObject"]{
                if isNotResolveConnectingStationTime && stationJsonObject == nextTrainTimeTableJsonObject["odpt:trainTimetableObject"].first!{
                    continue
                }
                
                let object = TimetableObject()
                object.train = nextTrain
                
                var arrivalStationCode = ""
                if let s = stationJsonObject.1["odpt:departureStation"].string{
                    arrivalStationCode = s
                }else if let s = stationJsonObject.1["odpt:arrivalStation"].string{
                    arrivalStationCode = s
                }
                
                if self.station.stationCode == arrivalStationCode{
                    object.departureStation = self.station
                }else{
                    object.departureStation = self.otherStations.filter({$0.stationCode == arrivalStationCode})[0]
                }
                
                if let arrivalTime = stationJsonObject.1["odpt:arrivalTime"].string{
                    object.departureTimeTitle = arrivalTime
                }else{
                    object.departureTimeTitle = stationJsonObject.1["odpt:departureTime"].stringValue
                }
                
                var departureTimeArray = [
                    Int(object.departureTimeTitle.split(separator: ":")[0])!,
                    Int(object.departureTimeTitle.split(separator: ":")[1])!
                ]
                
                if departureTimeArray[0] <= 4{
                    departureTimeArray[0] += 24
                }
                
                guard let departureTime = calendar.date(from: DateComponents.init(timeZone: .autoupdatingCurrent, year: calendar.component(.year, from: selectedDateOnPicker), month: calendar.component(.month, from: selectedDateOnPicker), day: calendar.component(.day, from: selectedDateOnPicker), hour: departureTimeArray[0], minute: departureTimeArray[1])) else{
                    fatalError()
                }
                
                object.departureTime = departureTime
                departureTimeList.append(object)
            }
            
        }
        
        let alert = UIAlertController(title: "降車駅を選択してください", message: "他路線直通列車を利用する場合で、直通先の駅名が出ない場合は、この列車の最後の停車駅を選択してください。\n列車時刻表が提供されていない鉄道会社（例：西武鉄道）の路線では、降車駅選択はできません。", preferredStyle: .alert)
        for arrivalStation in departureTimeList{
            alert.addAction(UIAlertAction(title: "\(arrivalStation.departureStation.stationName) (\(arrivalStation.departureTimeTitle!)着)", style: .default, handler: {action in
                self.chooseLeaveStation(selectedTrain: selectedTrain, timetableObject: arrivalStation)
            }))
        }

        alert.addAction(UIAlertAction(title: "キャンセル", style: .destructive, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func chooseLeaveStation(selectedTrain:Train, timetableObject: TimetableObject){
        let routeShapeObject = RouteShapeBase()
        routeShapeObject.isFinal = true
        routeShapeObject.originStationCode = station
        routeShapeObject.originStationDepartureTime = selectedTrain.departureTime
        routeShapeObject.destinationStationCode = timetableObject.departureStation
        routeShapeObject.destinationStationArrivalTime = timetableObject.departureTime
        routeShapeObject.railwayCode = self.railway
        routeShapeObject.train = selectedTrain
        
        let routeShapeResultViewController = self.presentingViewController?.presentingViewController?.presentingViewController as! RailwayRouteShapeConfirm
        
        if routeShapeResultViewController.routeShape.count != 0{
            routeShapeResultViewController.routeShape.last!.isFinal = false
        }
        
        routeShapeResultViewController.routeShape.append(routeShapeObject)
        routeShapeResultViewController.summaryView.reloadData()
        
        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
