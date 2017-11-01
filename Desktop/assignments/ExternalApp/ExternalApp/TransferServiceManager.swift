//
//  TransferServiceManager.swift
//  ExternalApp
//
//  Created by Niels Marsman on 07-10-2017.
//  Copyright © 2017 NielsMarsman. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class TransferServiceManager: NSObject
{
    public private(set) var services: [TransferService] = []
    
    init(with delegate: TransferServiceReceiveDelegate)
    {
        super.init()
        
        services.append(MultipeerTransferService(with: delegate))
        services.append(BLETransferService(with: delegate))
    }
}
