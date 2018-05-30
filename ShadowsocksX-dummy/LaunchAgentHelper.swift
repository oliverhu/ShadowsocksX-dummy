//
//  LaunchAgentHelper.swift
//  ShadowsocksX-dummy
//
//  Modified by Keqiu Hu on 5/29/18.
//  Copyright © 2018 Keqiu Hu. All rights reserved.

//  Created by 邱宇舟 on 16/6/6.
//  Copyright © 2016年 qiuyuzhou. All rights reserved.
//

import Foundation

let SS_LOCAL_VERSION = "3.1.3"
let KCPTUN_CLIENT_VERSION = "20170322"
let PRIVOXY_VERSION = "3.0.26.static"
let SIMPLE_OBFS_VERSION = "0.0.2"
let APP_SUPPORT_DIR = "/Library/Application Support/ShadowsocksX-dummy/"
let LAUNCH_AGENT_DIR = "/Library/LaunchAgents/"
let LAUNCH_AGENT_CONF_SSLOCAL_NAME = "com.chuanyue.shadowsocksX-dummy.local.plist"

func SyncSSLocal() {
    var changed: Bool = false
    changed = changed || generateSSLocalLauchAgentPlist()
    let mgr = ServerProfileManager.shared
    if let profile = mgr.currentProfile {
        changed = changed || writeSSLocalConfFile((profile.toJsonConfig()))
    }

    let on = true //UserDefaults.standard.bool(forKey: "ShadowsocksOn")
    if on {
        if changed {
            StopSSLocal()
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1),
                execute: {
                    () in
                    StartSSLocal()
            })
        } else {
            StartSSLocal()
        }
    } else {
        StopSSLocal()
    }

}

func getFileSHA1Sum(_ filepath: String) -> String {
    if FileManager.default.fileExists(atPath: filepath) {
        return SHA1.hexString(fromFile: filepath)!
    } else {
        FileManager.default.createFile(atPath: filepath, contents: nil, attributes: nil)
        return ""
    }
}

// Ref: https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html
// Genarate the mac launch agent service plist

//  MARK: sslocal

func generateSSLocalLauchAgentPlist() -> Bool {
    let sslocalPath = NSHomeDirectory() + APP_SUPPORT_DIR + "ss-local-latest/ss-local"
    let logFilePath = NSHomeDirectory() + "/Library/Logs/ss-local.log"
    let launchAgentDirPath = NSHomeDirectory() + LAUNCH_AGENT_DIR
    let plistFilepath = launchAgentDirPath + LAUNCH_AGENT_CONF_SSLOCAL_NAME

    // Ensure launch agent directory is existed.
    let fileMgr = FileManager.default
    if !fileMgr.fileExists(atPath: launchAgentDirPath) {
        try! fileMgr.createDirectory(atPath: launchAgentDirPath, withIntermediateDirectories: true, attributes: nil)
    }

    let oldSha1Sum = getFileSHA1Sum(plistFilepath)

    let defaults = UserDefaults.standard
    let enableUdpRelay = defaults.bool(forKey: "LocalSocks5.EnableUDPRelay")
    let enableVerboseMode = defaults.bool(forKey: "LocalSocks5.EnableVerboseMode")

    var arguments = [sslocalPath, "-c", "ss-local-config.json"]
    if enableUdpRelay {
        arguments.append("-u")
    }
    if enableVerboseMode {
        arguments.append("-v")
    }
    arguments.append("--reuse-port")

    // For a complete listing of the keys, see the launchd.plist manual page.
    let dict: NSMutableDictionary = [
        "Label": "com.chuanyue.shadowsocksX-dummy.local",
        "WorkingDirectory": NSHomeDirectory() + APP_SUPPORT_DIR,
        "StandardOutPath": logFilePath,
        "StandardErrorPath": logFilePath,
        "ProgramArguments": arguments,
        "EnvironmentVariables": ["DYLD_LIBRARY_PATH": NSHomeDirectory() + APP_SUPPORT_DIR + "ss-local-latest/"]
    ]
    dict.write(toFile: plistFilepath, atomically: true)
    let Sha1Sum = getFileSHA1Sum(plistFilepath)
    if oldSha1Sum != Sha1Sum {
        NSLog("generateSSLocalLauchAgentPlist - File has been changed.")
        return true
    } else {
        NSLog("generateSSLocalLauchAgentPlist - File has not been changed.")
        return false
    }
}

func StartSSLocal() {
    let bundle = Bundle.main
    let installerPath = bundle.path(forResource: "start_ss_local.sh", ofType: nil)
    let task = Process.launchedProcess(launchPath: installerPath!, arguments: [""])
    task.waitUntilExit()
    if task.terminationStatus == 0 {
        NSLog("Start ss-local succeeded.")
    } else {
        NSLog("Start ss-local failed.")
    }
}

func StopSSLocal() {
    let bundle = Bundle.main
    let installerPath = bundle.path(forResource: "stop_ss_local.sh", ofType: nil)
    let task = Process.launchedProcess(launchPath: installerPath!, arguments: [""])
    task.waitUntilExit()
    if task.terminationStatus == 0 {
        NSLog("Stop ss-local succeeded.")
    } else {
        NSLog("Stop ss-local failed.")
    }
}

func InstallSSLocal() {
    let fileMgr = FileManager.default
    let homeDir = NSHomeDirectory()
    let appSupportDir = homeDir+APP_SUPPORT_DIR
    if !fileMgr.fileExists(atPath: appSupportDir + "ss-local-\(SS_LOCAL_VERSION)/ss-local")
        || !fileMgr.fileExists(atPath: appSupportDir + "ss-local-\(SS_LOCAL_VERSION)/libmbedcrypto.0.dylib") {
        let bundle = Bundle.main
        let installerPath = bundle.path(forResource: "install_ss_local.sh", ofType: nil)
        let task = Process.launchedProcess(launchPath: installerPath!, arguments: [""])
        task.waitUntilExit()
        if task.terminationStatus == 0 {
            NSLog("Install ss-local succeeded.")
        } else {
            NSLog("Install ss-local failed.")
        }
    }
}

func writeSSLocalConfFile(_ conf:[String: Any]) -> Bool {
    do {
        let filepath = NSHomeDirectory() + APP_SUPPORT_DIR + "ss-local-config.json"
        let data: Data = try JSONSerialization.data(withJSONObject: conf, options: .prettyPrinted)

        let oldSum = getFileSHA1Sum(filepath)
        try data.write(to: URL(fileURLWithPath: filepath), options: .atomic)
        let newSum = SHA1.hexString(fromFile: filepath)!

        if oldSum == newSum {
            NSLog("writeSSLocalConfFile - File has not been changed.")
            return false
        }

        NSLog("writeSSLocalConfFile - File has been changed.")
        return true
    } catch {
        NSLog("Write ss-local file failed.\(error)")
    }
    return false
}

func removeSSLocalConfFile() {
    do {
        let filepath = NSHomeDirectory() + APP_SUPPORT_DIR + "ss-local-config.json"
        try FileManager.default.removeItem(atPath: filepath)
    } catch {

    }
}
