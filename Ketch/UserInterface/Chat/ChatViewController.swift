//
//  ChatViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import EDColor

@objc(ChatViewController)
class ChatViewController : JSQMessagesViewController, JSQMessagesCollectionViewDataSource {
    
    var connection: Connection?
    private var messages : FetchViewModel!
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var outgoingBubbleData : JSQMessagesBubbleImage!
    var incomingBubbleData : JSQMessagesBubbleImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Make this configurable from storyboard. JSQMessages library annoyingly
        // resets its own color to white when configuring itself
        view.backgroundColor = UIColor(hex: 0x0BE5F1)
        collectionView.backgroundColor = UIColor.clearColor()
        
        inputToolbar.contentView.leftBarButtonItem = nil

        let bubbleFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleData = bubbleFactory.outgoingMessagesBubbleImageWithColor(StyleKit.darkWhite)
        incomingBubbleData = bubbleFactory.incomingMessagesBubbleImageWithColor(StyleKit.pureWhite)
        
        assert(connection != nil, "Connection being nil is not supported on chatVC")
        
        messages = FetchViewModel(frc: connection!.fetchMessages(sorted: true))
        messages.performFetchIfNeeded()
        messages.signal.subscribeNext { [weak self] _ in
            // Surely there must be a way to do this one message at a time rather than
            // reloading the entire view?
            self?.collectionView.reloadData()
            self?.scrollToBottomAnimated(true)
            return
        }
        
        avatarView.sd_setImageWithURL(connection?.user?.profilePhotoURL)
        nameLabel.text = connection?.user?.firstName
        avatarView.whenTapped { [weak self] in
            self?.performSegue(.ChatToProfile)
            return
        }
        
        let avatarLength = 30
        let layout = self.collectionView.collectionViewLayout
        layout.incomingAvatarViewSize = CGSizeZero
        layout.outgoingAvatarViewSize = CGSizeZero
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarView.makeCircular()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileVC = segue.destinationViewController as? ProfileViewController {
            profileVC.user = connection?.user
        }
    }
    
    // MARK: -
    
    @IBAction func goBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - 
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if let connectionID = connection?.documentID {
            Core.meteor.callMethod("connection/sendMessage", params: [connectionID, text])
        }
        finishSendingMessageAnimated(true)
    }
    
    // MARK: - JSQMessagesCollectionViewDataSource
    
    func senderDisplayName() -> String! {
        return User.currentUser()?.firstName
    }
    
    func senderId() -> String! {
        return User.currentUser()?.documentID
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.numberOfItemsInSection(section)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        // This doesn't work if layout changes (say diff avatar size). So need to figure out better way
        cell.avatarImageView.makeCircular()
        cell.textView.textColor = StyleKit.navy
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return (messages.itemAtIndexPath(indexPath) as Message).jsqMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages.itemAtIndexPath(indexPath) as Message
        return message.sender!.isCurrentUser ? outgoingBubbleData : incomingBubbleData
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages.itemAtIndexPath(indexPath) as Message
        return message.sender?.jsqAvatar();
    }
    
    // MARK: - Class Method
    
    override class func nib() -> UINib {
        return UINib(nibName: "ChatView", bundle: nil)
    }
}
