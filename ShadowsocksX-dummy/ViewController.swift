//
//  ViewController.swift
//  ShadowsocksX-dummy
//
//  Created by Keqiu Hu on 5/29/18.
//  Copyright © 2018 Keqiu Hu. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    static let METHOD: String = "method"
    static let SERVER: String = "server"
    static let PASSWORD: String = "password"
    static let LOCAL_ADDRESS: String = "local_address"
    static let LOCAL_PORT: String = "local_port"
    static let SERVER_PORT: String = "server_port"
    static let PAC: String = "pac_url"

    @IBOutlet weak var host: NSTextField!
    @IBOutlet weak var port: NSTextField!
    @IBOutlet weak var password: NSTextField!
    @IBOutlet weak var localIP: NSTextField!
    @IBOutlet weak var localPort: NSTextField!
    @IBOutlet weak var method: NSTextField!
    @IBOutlet weak var remember: NSButton!
    @IBOutlet weak var pacBox: NSButton!

    @IBOutlet weak var pac: NSTextField!

    @IBOutlet weak var connect: NSButton!

    let ud = UserDefaults.standard

    @IBAction func autoPacTapped(_ sender: Any) {
        updateUI()
    }

    func updateUI() {
        if pacBox.state == NSControl.StateValue.on {
            localIP.isEnabled = true
            localPort.isEnabled = true
            pac.isEnabled = true
        } else {
            localIP.isEnabled = false
            localPort.isEnabled = false
            pac.isEnabled = false
        }

    }


    @IBAction func connectTapped(_ sender: Any) {
        if connect.title == "Disconnect" {
            ProxyConfHelper.disableProxy()
            connect.title = "Connect"
        } else {
            if remember.state == NSControl.StateValue.on {
                ud.set(host.stringValue, forKey: ViewController.SERVER)
                ud.set(method.stringValue, forKey: ViewController.METHOD)
                ud.set(password.stringValue, forKey: ViewController.PASSWORD)
                ud.set(localIP.stringValue, forKey: ViewController.LOCAL_ADDRESS)
                ud.set(Int(localPort.stringValue), forKey: ViewController.LOCAL_PORT)
                ud.set(Int(port.stringValue), forKey: ViewController.SERVER_PORT)
                ud.set(pac.stringValue, forKey: ViewController.PAC)
            }
            ServerProfileManager.shared.currentProfile = ServerProfile(sessionId: UUID().uuidString, serverAddress: host.stringValue, serverPort: Int(port.stringValue)!, password: password.stringValue, localAddress: localIP.stringValue, method: method.stringValue, localPort: Int(localPort.stringValue)!)
            UserDefaults.standard.set(Int(localPort.stringValue)!, forKey: "LocalSocks5.ListenPort")
            UserDefaults.standard.set(pac.stringValue, forKey: "PAC.URL")
            InstallSSLocal()
            ProxyConfHelper.install()
            if pacBox.state == NSControl.StateValue.on {
                ProxyConfHelper.enablePACProxy()
            } else {
                ProxyConfHelper.enableGlobalProxy()
            }

            SyncSSLocal()
            connect.title = "Disconnect"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let host = ud.value(forKey: ViewController.SERVER) as? String,
            let method = ud.value(forKey: ViewController.METHOD) as? String,
            let password = ud.value(forKey: ViewController.PASSWORD) as? String,
            let serverPort = ud.value(forKey: ViewController.SERVER_PORT) as? Int,
            let localPort = ud.value(forKey: ViewController.LOCAL_PORT) as? Int,
            let pac = ud.value(forKey: ViewController.PAC) as? String,
            let localIp = ud.value(forKey: ViewController.LOCAL_ADDRESS) as? String {
            self.host.stringValue = host
            self.method.stringValue = method
            self.password.stringValue = password
            self.port.stringValue = "\(serverPort)"
            self.localPort.stringValue = "\(localPort)"
            self.localIP.stringValue = localIp
            self.pac.stringValue = pac
        }
        updateUI()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

