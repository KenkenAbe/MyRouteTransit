//
//  ViewController.swift
//  MyRouteTransit
//
//  Created by Kentaro on 2019/12/23.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import UIKit
import RealmSwift

class SavedRouteShapeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var realm:Realm!
    var savedRoutes:Results<RouteShape>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.realm = try! Realm()
        
        self.savedRoutes = self.realm.objects(RouteShape.self).sorted(byKeyPath: "id", ascending: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.savedRoutes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedRouteShapeCell") as! SavedRouteShapeCell
        
        return cell
    }
    

}

