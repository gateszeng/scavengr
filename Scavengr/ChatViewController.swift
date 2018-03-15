//
//  ChatViewController.swift
//  Scavengr
//
//  Created by Gates Zeng on 3/14/18.
//  Copyright © 2018 Gates Zeng. All rights reserved.
//

import UIKit
import PubNub

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PNObjectEventListener {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    let channelName = "main"
    
    var messages: [String]?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var pnClient: PubNub?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        
        // set client and subscribe to channel
        pnClient = appDelegate.client
        pnClient?.subscribeToChannels([channelName], withPresence: false)
        pnClient?.addListener(self)
        
        messages = [String]()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("message count \(messages?.count)")
        return messages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
        
        let message = messages![indexPath.row]
        cell.messageLabel.text = message
        return cell
    }
    
    @IBAction func onSend(_ sender: AnyObject) {
        let text = textField.text
        if let text = text {
            let convertedText = ScavengerEngine.parseText(text: text)
            self.textField.text = ""
            print("convertedText \(convertedText)")
            
            // send the parsed message
            sendMessage(message: convertedText)
            
            // synchronize if user was correct
            if (convertedText.hasPrefix("Correct!")) {
                sendMessage(message: "/resQ \(ScavengerEngine.currQ)")
            }
            
        }
    }

    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        // check message if message is synchronization info
        let receivedMessage = ScavengerEngine.newMessage(text: message.data.message as! String)
        
        // send synchronization message if requested
        if receivedMessage.hasPrefix("/resQ") {
            sendMessage(message: receivedMessage)
        }
        // regular message, add to messages
        else if receivedMessage.characters.count > 0 && !receivedMessage.hasPrefix("/"){
            messages?.append(message.data.message! as! String)
            tableView.reloadData()
            self.scrollToBottom(animated: true)
        }

        print("Received message: \(message.data.message!) on channel \(message.data.channel) " +
            "at \(message.data.timetoken)")
    }
    
    
    func client(_ client: PubNub, didReceive status: PNStatus) {
        if status.operation == .subscribeOperation {
            
            // synchronize to get question number when joining room
            if status.category == .PNConnectedCategory {
                sendMessage(message: "/reqQ")
            }
        }
    }
    
    // function to send a message
    func sendMessage(message: String) {
        pnClient?.publish(message, toChannel: channelName, withCompletion: { (status) in
            print("message \(message) sent")
        })
    }
    
    // pretty scroll to bottom
    func scrollToBottom(animated: Bool) {
        let numberOfSections = self.tableView.numberOfSections
        let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
