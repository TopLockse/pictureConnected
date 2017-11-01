//
//  String+ExternalApp.swift
//  ExternalApp
//
//  Created by Niels Marsman on 08-10-2017.
//  Copyright © 2017 NielsMarsman. All rights reserved.
//

import Foundation

extension String
{
    static func localized(_ key: String) -> String
    {
        return NSLocalizedString(key, comment: "")
    }
    
    static func localized(_ key: String, argument: String) -> String
    {
        return String.localizedStringWithFormat(NSLocalizedString(key, comment: ""), argument)
    }
}
