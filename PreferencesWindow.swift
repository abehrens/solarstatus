//
//  PreferencesWindow.swift
//  Solar Status
//
//  Created by Alex Behrens on 3/12/16.
//  Copyright © 2016 Alex Behrens. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    @IBOutlet weak var systemIdTextField: NSTextField!
    @IBOutlet weak var apiKeyTextField: NSTextField!
    @IBOutlet weak var userIdTextField: NSTextField!
    @IBOutlet weak var updateFrequencyTextField: NSTextField!
    
    var delegate: PreferencesWindowDelegate?
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    func windowWillClose(notification: NSNotification) {
        self.savePreferences()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
        let defaults = NSUserDefaults.standardUserDefaults()
        systemIdTextField.stringValue = defaults.stringForKey("systemId") ?? ""
        apiKeyTextField.stringValue = defaults.stringForKey("apiKey") ?? ""
        userIdTextField.stringValue = defaults.stringForKey("userId") ?? ""
        updateFrequencyTextField.doubleValue = defaults.objectForKey("updateFrequency") as? Double ?? 300.0
    }
    
    func savePreferences() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(systemIdTextField.stringValue, forKey: "systemId")
        defaults.setValue(apiKeyTextField.stringValue, forKey: "apiKey")
        defaults.setValue(userIdTextField.stringValue, forKey: "userId")
        defaults.setValue(updateFrequencyTextField.doubleValue, forKey: "updateFrequency")
        delegate?.preferencesDidUpdate()
    }
    
    @IBAction func saveClicked(sender: AnyObject) {
        self.savePreferences()
        self.close()
    }
}
