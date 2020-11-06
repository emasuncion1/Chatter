//
//  ViewController.swift
//  Chatter
//
//  Created by Errol Asuncion on 11/4/20.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    var peerID: MCPeerID! // identifies the user inside a session
    var mcSession: MCSession! // handles multipeer connectivity
    var mcAdvertiserAssistant: MCAdvertiserAssistant! // advertise sessions and handles invitations
    var messageToSend: String! // plain string to display to text view
    
    @IBOutlet weak var chatView: UITextView!
    @IBOutlet weak var inputMsg: UITextField!
    @IBAction func sendBtn(_ sender: Any) {
        messageToSend = "\(peerID.displayName): \(inputMsg.text!)\n"
        let message = messageToSend.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        do {
            try self.mcSession.send(message!, toPeers: self.mcSession.connectedPeers, with: .unreliable)
            chatView.text = chatView.text + messageToSend
            inputMsg.text = ""
        } catch {
            print("Error sending message!")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showConnectionMenu))
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func showConnectionMenu() {
        let ac = UIAlertController(title: "Connection Menu", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: hostSession))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
      }
    
    func hostSession(action: UIAlertAction) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "chatter", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func joinSession(action: UIAlertAction) {
        let mcBrowser = MCBrowserViewController(serviceType: "chatter", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
        case.connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not connected: \(peerID.displayName)")
        @unknown default:
            print("error")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            [unowned self] in
            let message = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
            self.chatView.text = self.chatView.text + message
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Do nothing
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Do nothing
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Do nothing
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}

