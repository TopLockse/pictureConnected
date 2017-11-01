//
//  MultipeerTransferService.swift
//  ExternalApp
//
//  Created by Niels Marsman on 08-10-2017.
//  Copyright © 2017 NielsMarsman. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MultipeerTransferService: NSObject
{
    public var delegate: TransferServiceDelegate?
    private let receiveDelegate: TransferServiceReceiveDelegate!
    
    public var service: TransferServiceType { return .wifi }
    public var peers: [String] { return found.map { $0.displayName } }
    public private(set) var status: String = "Idle"
    
    private let peer = MCPeerID(displayName: UIDevice.current.name)
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    
    private lazy var session: MCSession =
    {
        var session = MCSession(peer: self.peer, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    private var found: [MCPeerID] = []
    private var queue: [MCPeerID: TransferFile] = [:]
    
    public required init(with delegate: TransferServiceReceiveDelegate)
    {
        receiveDelegate = delegate
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: AppConfiguration.multipeerService)
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: AppConfiguration.multipeerService)
        
        super.init()
        
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        
        browser.delegate = self
    }
}

// MARK: TransferService
extension MultipeerTransferService: TransferService
{
    public func send(file: TransferFile, to peer: Int)
    {
        status = "Sending"
        delegate?.status()
        
        queue[found[peer]] = file
        browser.invitePeer(found[peer], to: session, withContext: nil, timeout: 10)
    }
    
    public func scan()
    {
        browser.startBrowsingForPeers()
        delegate?.update()
    }
}

// MARK: Advertising
extension MultipeerTransferService: MCNearbyServiceAdvertiserDelegate
{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error)
    {
        print("Did not start advertising: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peer: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void)
    {
        receiveDelegate.handleInvitation(from: peer.displayName, onAccept:
        {
            [weak self] in
            
            invitationHandler(true, self?.session)
        }, onDecline:
        {
            [weak self] in
            
            invitationHandler(false, self?.session)
        })
    }
}

// MARK: Browsing
extension MultipeerTransferService: MCNearbyServiceBrowserDelegate
{
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error)
    {
        print("Did not start browsing: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peer: MCPeerID, withDiscoveryInfo info: [String : String]?)
    {
        if found.filter({ p in p.displayName == peer.displayName }).count == 0
        {
            found.append(peer)
            delegate?.update()
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peer: MCPeerID)
    {
        print("Lost peer: \(peer)")
        if let peer = found.index(where: { $0 == peer })
        {
            found.remove(at: peer)
            delegate?.update()
        }
    }
}

// MARK: Session
extension MultipeerTransferService: MCSessionDelegate
{
    func session(_ session: MCSession, peer: MCPeerID, didChange state: MCSessionState)
    {
        if state == .connected && session.connectedPeers.contains(peer),
            let data = queue[peer]
        {
            switch data
            {
                case let .data(_, data): try? session.send(data, toPeers: [peer], with: .reliable)
                case let .url(resource, url): session.sendResource(at: url, withName: resource, toPeer: peer, withCompletionHandler: nil)
            }
            
            status = "Idle"
            delegate?.status()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peer: MCPeerID)
    {
        if let a = CGImageSourceCreateWithData(data as CFData, nil)
        {
            let b = CGImageSourceCopyPropertiesAtIndex(a, 0, nil)
            
            if let dict = b as? [String: Any]
            {
                print(dict)
            }
        }
        
        if let image = UIImage.init(data: data)
        {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            receiveDelegate.saved()
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID)
    {
        print("Did receive stream with name: \(streamName)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peer: MCPeerID, with progress: Progress)
    {
        print("Did start receiving resource with name: \(resourceName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peer: MCPeerID, at local: URL?, withError error: Error?)
    {
        if let error = error
        {
            print("Did finish receiving resource with error: \(error)")
            return
        }
        
        guard let local = local else
        {
            print("Local url is lost?")
            return
        }
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let destination = documents[0].appendingPathComponent(resourceName)
        
        do
        {
            if FileManager.default.fileExists(atPath: destination.absoluteString)
            {
                try FileManager.default.removeItem(at: destination)
            }
            
            try FileManager.default.copyItem(at: local, to: destination)
        }
        catch
        {
            print("Error copying file: \(error)")
        }
        
        receiveDelegate.saved()
    }
}
