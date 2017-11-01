//
//  AppNavigationController.swift
//  ExternalApp
//
//  Created by Niels Marsman on 07-10-2017.
//  Copyright © 2017 NielsMarsman. All rights reserved.
//

import UIKit

class AppNavigationController: UINavigationController
{
    public private(set) var serviceManager: TransferServiceManager?
    
    override func viewDidLoad()
    {
        serviceManager = TransferServiceManager(with: self)
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}

extension AppNavigationController: TransferServiceReceiveDelegate
{
    func handleInvitation(from name: String, onAccept accept: @escaping () -> Void, onDecline decline: @escaping () -> Void)
    {
        let questionController = UIAlertController(title: .localized("invitation.title"), message: .localized("invitation.description", argument: name), preferredStyle: .alert)
        
        questionController.addAction(UIAlertAction(title: .localized("button.decline"), style: .destructive, handler:
        {
            action in
            
            decline()
        }))
        
        questionController.addAction(UIAlertAction(title: .localized("button.accept"), style: .default, handler:
        {
            action in
            
            accept()
        }))
        
        self.present(questionController, animated: true)
    }
    
    func saved()
    {
        let alertController = UIAlertController(title: "De afbeelding is opgeslagen", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alertController, animated: true)
    }
}
