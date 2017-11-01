//
//  ConnSercviceManaging.swift
//  pictureConnected
//
//  Created by MacTop on 08-10-17.
//  Copyright © 2017 MacTop. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class PCServiceManager : NSObject{
    
    private let PCServiceType = "PC-MC-LTO" //ColorServiceType
    private let myServiceID = MCPeerID(displayName: UIDevice.current.name)//myPeerID
    private let myServiceAdvertiser : MCNearbyServiceAdvertiser
    private let myServicesBrowser :  MCNearbyServiceBrowser
    public var statusMessage : String
    var delegate : PCServiceManagerDelegate?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myServiceID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    override init(){
        self.myServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myServiceID, discoveryInfo: nil, serviceType: PCServiceType)
        self.myServicesBrowser = MCNearbyServiceBrowser(peer: myServiceID, serviceType:PCServiceType) //why our own service id??
        statusMessage = " let's start scanning!"
        
        super.init()
        
        self.myServiceAdvertiser.delegate = self
        self.myServiceAdvertiser.startAdvertisingPeer()
        
        self.myServicesBrowser.delegate = self
        self.myServicesBrowser.startBrowsingForPeers()//try activating this in the UIController
        print(PCServiceType, "is created and started advertising")
        NSLog("%@", " logging works fine")
    }
    
    deinit{
        self.myServiceAdvertiser.stopAdvertisingPeer()
        self.myServicesBrowser.stopBrowsingForPeers()
        
        print(PCServiceType, "is destroyed and stopped advertising")
        statusMessage = "\(PCServiceType) stopped"
    }
    
    func sendHello(customMessage: String){
        NSLog("%@", "we send a message hello \(customMessage) to \(session.connectedPeers.count) peers!")
        statusMessage = "hello message send"
        if session.connectedPeers.count > 0{
            do{
                try self.session.send("hello".data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "wu-oh while sending \(error)")
            }
        }
    }
    
    func send(colorName : String){
        NSLog("%@", "we send a colormessage hello to \(session.connectedPeers.count) peers!")
        
        if session.connectedPeers.count > 0{
            do{
                try self.session.send(colorName.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "wu-oh while sending \(error)")
            }
        }
    }
    
    func send(picture : Data){
        NSLog("%@", "we send a picture to \(session.connectedPeers.count) peers!")
        
        if session.connectedPeers.count > 0{
            do{
                try self.session.send(picture, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "wu-oh while sending \(error)")
            }
        }
    }
    
    func send(image : UIImage){
        NSLog("%@", "we send a colormessage hello to \(session.connectedPeers.count) peers!")
   /*
        if session.connectedPeers.count > 0{
            do{
                try self.session.sendResource(at: <#T##URL#>, withName: <#T##String#>, toPeer: <#T##MCPeerID#>, withCompletionHandler: <#T##((Error?) -> Void)?##((Error?) -> Void)?##(Error?) -> Void#>)
                    //self.session.send(statusMessage.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
                
               // send(colorName.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "wu-oh while sending \(error)")
            }
        }
 */
    }
}

extension PCServiceManager: MCNearbyServiceAdvertiserDelegate{
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "we did Not Start Advertising Peer: \(error)")
        statusMessage = "wu-oh: \(error)"
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "we did Receive Invition From Peer: \(peerID)")
        invitationHandler(true, self.session)
        statusMessage = "invite from: \(peerID)"
    }
}

extension PCServiceManager : MCNearbyServiceBrowserDelegate{
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "we did Not Start browsing for Peer: \(error)")
        statusMessage = "wu-oh: \(error)"
    }
    // active with scan button in UI
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "we found a Peer while browsing: \(peerID)")
                NSLog("%@", "invited Peer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        statusMessage = "found: \(peerID) and invite"
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "oh no we lost a Peer : \(peerID)")
        statusMessage = "lost: \(peerID)"
    }
    
}

extension PCServiceManager : MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "this peer: \(peerID)changed state to:\(state)")
        self.delegate?.connectedDeviceChanged(manger: self, connectedDevices: session.connectedPeers.map{$0.displayName})
        statusMessage = "\(peerID) changed "
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "received data from: \(peerID)! look:\(data)")
        //let str = String(data:data, encoding: .utf8)!
        //self.delegate?.receivedMessages(manager: self, message: str)
        self.delegate?.receivedPica(manager: self, message: data)
        statusMessage = "message from: \(peerID)"
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "received stream from: \(peerID)!")
        statusMessage = "message from: \(peerID)"
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "received message from: \(peerID) with name: \(resourceName)")
        statusMessage = "received something: \(resourceName)"
        //show progress
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "received message from: \(peerID) with name: \(resourceName)")
        statusMessage = "received something: \(resourceName)"
        //show progress
    }
}

protocol PCServiceManagerDelegate{
    func connectedDeviceChanged( manger: PCServiceManager, connectedDevices : [ String])
    func receivedMessages( manager : PCServiceManager, message: String)
    func receivedPica( manager : PCServiceManager, message: Data)
}



