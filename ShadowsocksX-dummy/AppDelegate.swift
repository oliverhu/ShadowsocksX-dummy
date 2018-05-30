//
//  AppDelegate.swift
//  ShadowsocksX-dummy
//
//  Created by Keqiu Hu on 5/29/18.
//  Copyright © 2018 Keqiu Hu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func ensureLaunchAgentsDirOwner () {
        let dirPath = NSHomeDirectory() + "/Library/LaunchAgents"
        let fileMgr = FileManager.default
        if fileMgr.fileExists(atPath: dirPath) {
            do {
                let attrs = try fileMgr.attributesOfItem(atPath: dirPath)
                if attrs[FileAttributeKey.ownerAccountName] as! String != NSUserName() {
                    //try fileMgr.setAttributes([FileAttributeKey.ownerAccountName: NSUserName()], ofItemAtPath: dirPath)
                    let bashFilePath = Bundle.main.path(forResource: "fix_dir_owner.sh", ofType: nil)!
                    let script = "do shell script \"bash \\\"\(bashFilePath)\\\" \(NSUserName()) \" with administrator privileges"
                    if let appleScript = NSAppleScript(source: script) {
                        var err: NSDictionary? = nil
                        appleScript.executeAndReturnError(&err)
                    }
                }
            }
            catch {
                NSLog("Error when ensure the owner of $HOME/Library/LaunchAgents, \(error.localizedDescription)")
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        ensureLaunchAgentsDirOwner()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        ProxyConfHelper.disableProxy()
    }


}

