//
//  StatusMenuController.swift
//  Solar Status
//
//  Created by Alex Behrens on 3/11/16.
//  Copyright © 2016 Alex Behrens. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, PreferencesWindowDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    var solarAPI: SolarAPI
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let prefs = NSUserDefaults.standardUserDefaults()
    var kwhFormatter: NSNumberFormatter
    var preferencesWindow: PreferencesWindow!
    var timer = NSTimer()
    
    override init() {
        self.kwhFormatter = NSNumberFormatter()
        self.kwhFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        self.kwhFormatter.maximumFractionDigits = 1
        self.solarAPI = SolarAPI(apiKey: prefs.stringForKey("apiKey")!, userId: prefs.stringForKey("userId")!, systemId: prefs.stringForKey("systemId")!)
        super.init()
    }
    
    override func awakeFromNib() {
        statusItem.title = "Solar Status Initializing"
        statusItem.menu = statusMenu
        
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        self.update()
        self.startTimer()
    }
    
    func update() {
        solarAPI.fetchStatus(
            {status in self.updateStatus(status) },
            failure: {errorMessage in self.showError(errorMessage)}
        )
    }
    
    func updateStatus(status: Status) {
//        without styling
        let titleMessage = "\(status.lastUpdateTime): C \(formatPowerValue(status.currentPower)) | T \(formatPowerValue(status.energyToday))"
        statusItem.title = titleMessage
//      with styling
//        let titleMessage = "\(status.lastUpdateTime)\nC \(formatPowerValue(status.currentPower)) | T \(formatPowerValue(status.energyToday))"
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 0
//        let titleFont:NSFont = NSFont(name: "LucidaGrande", size: 10.0)!
//        let titleAttributes = [NSForegroundColorAttributeName: NSColor.blackColor(), String(kCTFontAttributeName): titleFont,NSParagraphStyleAttributeName: paragraphStyle]
//        let attributedTitleString = NSAttributedString(string: titleMessage, attributes: titleAttributes)
//        statusItem.attributedTitle = attributedTitleString
    }
    
    func showError(errorMessage: String) {
        self.stopTimer()
        statusItem.title = "Error: Check Settings"
    }
    
    func formatPowerValue(number: Int) -> String {
        if (number < 1000) {
            return "\(number)w"
        }
        else{
            return "\(self.kwhFormatter.stringFromNumber(Double(number ?? 0.0) / 1000.0)!)kw"
        }
    }
    
    func startTimer() {
        let updateFrequency = prefs.objectForKey("updateFrequency") as? Double ?? 300.0
        timer = NSTimer.scheduledTimerWithTimeInterval(updateFrequency, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    func preferencesDidUpdate() {
        self.stopTimer()
        self.solarAPI = SolarAPI(apiKey: prefs.stringForKey("apiKey")!, userId: prefs.stringForKey("userId")!, systemId: prefs.stringForKey("systemId")!)
        self.startTimer()
    }
    
    @IBAction func preferencesClicked(sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func updateClicked(sender: NSMenuItem) {
        self.update()
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

}
