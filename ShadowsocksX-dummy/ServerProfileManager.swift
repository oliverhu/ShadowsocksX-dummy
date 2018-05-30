//
//  ServerProfileManager.swift
//  ShadowsocksX-dummy
//
//  Created by Keqiu Hu on 5/29/18.
//  Copyright © 2018 Keqiu Hu. All rights reserved.
//

import Cocoa

struct ServerProfile {
    var sessionId: String // used to distinguish between different sessions.
    var serverAddress: String
    var serverPort: Int
    var password: String
    var localAddress: String
    var method: String
    var localPort: Int
    func toJsonConfig() -> [String: Any] {
        let conf: [String: Any] = [
            "method": method,
            "server": serverAddress,
            "password": password,
            "local_address": localAddress,
            "local_port": localPort,
            "server_port": serverPort,
            "timeout": 60
        ]
        return conf
    }
}
class ServerProfileManager {
    static let shared = ServerProfileManager()
    var currentProfile: ServerProfile?
}
