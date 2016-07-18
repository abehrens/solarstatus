//
//  SolarAPI.swift
//  Solar Status
//
//  Created by Alex Behrens on 3/11/16.
//  Copyright © 2016 Alex Behrens. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Status: CustomStringConvertible {
    var systemId: Int
    var currentPower: Int
    var energyToday: Int
    var energyLifetime: Int
    var lastReportAt: Int
    var status: String
    
    var description: String {
        return "System ID: \(systemId): Current Power \(currentPower), Energy Today \(energyToday), Status \(status)"
    }
    
    var lastUpdateTime: String {
        // yuck, this should go somewhere else
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d @ hh:mm a"
        let lastReportDate = NSDate(timeIntervalSince1970: NSTimeInterval(self.lastReportAt))
        return dateFormatter.stringFromDate(lastReportDate)
    }
}


class SolarAPI {
    let BASE_URL = "https://api.enphaseenergy.com/api/v2/"
    let requestUrl: NSURL
    
    init(apiKey: String, userId: String, systemId: String) {
        self.requestUrl = NSURL(string: "\(BASE_URL)/systems/\(systemId)/summary?key=\(apiKey)&user_id=\(userId)")!
    }
    
    func fetchStatus(success: (Status) -> Void, failure: (String) -> Void) {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(requestUrl) { data, response, error in
            if let httpResponse = response as? NSHTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    if let status = self.statusData(data!){
                        success(status)
                    }
                case 401:
                    NSLog("Solar API returned an 'unauthorized' response. Did you set your API key?")
                    failure("Solar API returned an 'unauthorized' response. Did you set your API key?")
                default:
                    NSLog("Solar API returned response: %d %@", httpResponse.statusCode, NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode))
                    failure("Solar API returned response: \(httpResponse.statusCode) \(data!)")
                }
            }
        }
        task.resume()
    }
    
    func statusData(data: NSData) -> Status? {
        var json = JSON(data: data)
        
        let status = Status(
            systemId: json["system_id"].intValue,
            currentPower: json["current_power"].intValue,
            energyToday: json["energy_today"].intValue,
            energyLifetime: json["energy_lifetime"].intValue,
            lastReportAt: json["last_report_at"].intValue,
            status: json["status"].stringValue
        )
        return status
    }
}