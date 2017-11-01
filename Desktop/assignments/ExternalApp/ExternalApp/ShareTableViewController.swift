//
//  ShareTableViewController.swift
//  ExternalApp
//
//  Created by Niels Marsman on 08-10-2017.
//  Copyright © 2017 NielsMarsman. All rights reserved.
//

import UIKit

class ShareTableViewController: UITableViewController
{
    @IBOutlet weak var filePreview: UIImageView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var shareDescription: UILabel!
    
    // App should crash when one of these vars aren't set.
    public var file: TransferFile!
    public var service: TransferService!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupHeader()
        self.setupPreview()
    }
    
    private func setupHeader()
    {
        self.navigationItem.title = .localized("share.title")
        self.shareDescription.text = .localized("share.description")
        
        self.activityLabel.text = service.status
    }
    
    private func setupPreview()
    {
        switch self.file!
        {
            case let .data(_, data):
                filePreview.image = UIImage(data: data, scale: 1.0)
            
            case let .url(_, url):
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data, scale: 1.0)
                {
                    filePreview.image = image
                }
                else
                {
                    filePreview.isHidden = true
                }
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}

extension ShareTableViewController
{
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return service.peers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = service.peers[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let questionController = UIAlertController(title: .localized("share.request.title"), message: .localized("share.request.message", argument: service.peers[indexPath.row]), preferredStyle: .alert)
        
        questionController.addAction(UIAlertAction(title: .localized("button.cancel"), style: .destructive))
        questionController.addAction(UIAlertAction(title: .localized("button.share"), style: .default, handler:
        {
            [weak self] action in
            
            if let file = self?.file
            {
                self?.service.send(file: file, to: indexPath.row)
            }
        }))
        
        self.present(questionController, animated: true)
    }
}

extension ShareTableViewController: TransferServiceDelegate
{
    func status()
    {
        if let activity = self.activityLabel
        {
            activity.text = service.status
        }
    }
    
    func update()
    {
        self.tableView.reloadData()
    }
}
