//
//  NetworkMonitor.swift
//  JDKUpdater
//
//  Created by Gerrit Grunwald on 27.03.24.
//

import Foundation
import Observation
import Network


@Observable
final class NetworkMonitor {
    
    static let shared : NetworkMonitor = {
        let instance = NetworkMonitor()
        return instance
    }()
    
    var isConnected             = false {
        didSet {
            if isConnected {
                Task {
                    self.isOnline = await RestController.isConnected()
                }
            } else {
                self.isOnline = false
            }
        }
    }
    var isOnline                = false
    var isUsingMobileConnection = false // low data usage ( 3G / 4G / etc )
    
    private let networkMonitor = NWPathMonitor()
    
    
    private init() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected             = path.status == .satisfied
            self?.isUsingMobileConnection = path.usesInterfaceType(.cellular)
        }
        
        networkMonitor.start(queue: DispatchQueue.global())
    }
}
