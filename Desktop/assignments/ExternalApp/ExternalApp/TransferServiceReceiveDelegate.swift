//
//  TransferServiceReceiveDelegate.swift
//  ExternalApp
//
//  Created by Niels Marsman on 08-10-2017.
//  Copyright © 2017 NielsMarsman. All rights reserved.
//

import UIKit

protocol TransferServiceReceiveDelegate
{
    func handleInvitation(from name: String, onAccept accept: @escaping () -> Void, onDecline decline: @escaping () -> Void)
    
    func saved()
}
