//
//  Configuration.swift
//  MyRouteTransit
//
//  Created by Kentaro on 2019/12/23.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import Foundation

class Configuration{
    private var dict:Dictionary<String,String>!
    
    init() {
        guard let path = Bundle.main.path(forResource: "configuration", ofType: "plist") else{
            fatalError("COULD NOT FIND ANY CONFIGURATION FILE")
        }
        
        guard let dictObj = NSDictionary.init(contentsOfFile: path) as? Dictionary<String,String> else{
            fatalError("COULD NOT PARSE CONFIGURATION FILE")
        }
        
        self.dict = dictObj
    }
    
    subscript(key:String) -> String{
        if let value = self.dict[key]{
            return value
        }
        
        return ""
    }
}
