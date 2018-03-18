//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Ahmed Zaghloul on 2/7/18.
//  Copyright © 2018 RKAnjel. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import Kingfisher

class ChatViewController: JSQMessagesViewController {

    // MARK: Properties
    var channelRef: DatabaseReference?
    
    private lazy var messageRef: DatabaseReference = Database.database().reference().child("orders")
    fileprivate lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://chatchat-rw-cf107.appspot.com")
    
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    
    private var messages: [JSQMessage] = []
    var orderID:String!
    var receiverName :String!
    var newChat:Bool = false
    var driver_phone:String?
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputToolbar.contentView.textView.placeHolder = "write_msg_chat".localized()
        self.senderId = (CURRENT_USER?.mobile!)!
        self.senderDisplayName = (CURRENT_USER?.mobile!)!
        observeMessages()

        if newChat {
            let itemRef = messageRef.child(orderID).child("chat").child(Date().getStringFromDate())
            
            let messageItem:[String:Any] = [
                "phone": driver_phone ?? "0",
                "order": 0,
                "msg": "اهلا بك في خدمة الرسائل النصيه من تطبيق توصيله , سيتم توصيل طلبك فى اقرب وقت",
                ]
            itemRef.setValue(messageItem)
        }
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        let rightButton = UIButton(type: .system)
        let sendImage = #imageLiteral(resourceName: "ic_sendmdpi")
        rightButton.tintColor = appColor
        rightButton.setImage(sendImage, for: UIControlState.normal)
        
        self.inputToolbar.contentView.leftBarButtonItem = nil
        
        self.inputToolbar.contentView.rightBarButtonItemWidth = CGFloat(34.0)
        
        self.inputToolbar.contentView.rightBarButtonItem = rightButton

    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    // MARK: Collection view data source (and related) methods
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId { // 1
            cell.textView?.textColor = UIColor.white // 2
        } else {
            cell.textView?.textColor = UIColor.black // 3
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    // MARK: Firebase related methods
    
    private func observeMessages() {
//        messageRef = channelRef!.child("messages")
        let messageQuery = messageRef.child(orderID).child("chat").queryLimited(toLast:25).queryOrdered(byChild: "order")
        
        
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, Any>
            
            if let id = messageData["phone"] as! String!, let name = self.receiverName, let text = messageData["msg"] as! String!, text.count > 0 {
                self.addMessage(withId: id, name: name, text: text)
                self.finishReceivingMessage()
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // 1
        let itemRef = messageRef.child(orderID).child("chat").child(date.getStringFromDate())
        
        // 2
        let messageItem:[String:Any] = [
            "phone": senderId!,
            "order": self.messages.count,
            "msg": text!,
            ]
        
        // 3
        itemRef.setValue(messageItem)

        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
    }
    
    
    // MARK: UI and User Interaction
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: appColor)
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
}

