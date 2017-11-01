//
//  TransferFile.swift
//  ExternalApp
//
//  Created by Niels Marsman on 10-10-2017.
//  Copyright © 2017 NielsMarsman. All rights reserved.
//

import Foundation

enum TransferFile
{
    case data(String, Data)
    case url(String, URL)
    
    func resource() -> String
    {
        switch self
        {
            case let .data(resource, _): return resource
            case let .url(resource, _): return resource
        }
    }
}
