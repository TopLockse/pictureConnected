//
//  TransferService.swift
//  ExternalApp
//
//  Created by Niels Marsman on 08-10-2017.
//  Copyright © 2017 NielsMarsman. All rights reserved.
//

import Foundation

protocol TransferService
{
    var delegate: TransferServiceDelegate? { get set } 
    var service: TransferServiceType { get }
    var peers: [String] { get }
    var status: String { get }
    
    init(with: TransferServiceReceiveDelegate)
    
    func send(file: TransferFile, to: Int)
    func scan()
}

enum TransferServiceType: String
{
    case bluetooth = "Bluetooth LE"
    case wifi = "WiFi"
}
