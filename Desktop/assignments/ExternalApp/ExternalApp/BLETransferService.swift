//
//  BLETransferService.swift
//  ExternalApp
//
//  Created by Niels Marsman on 08-10-2017.
//  Copyright © 2017 NielsMarsman. All rights reserved.
//

import Foundation

class BLETransferService
{
    var delegate: TransferServiceDelegate?
    var service: TransferServiceType { return .bluetooth }
    var status: String { return "Idle" }
    
    public private(set) var peers: [String] = []
    
    required init(with delegate: TransferServiceReceiveDelegate)
    {
        
    }
}

// MARK: TransferService
extension BLETransferService: TransferService
{
    public func send(file: TransferFile, to peer: Int)
    {
        
    }
    
    public func scan()
    {
        
    }
}
