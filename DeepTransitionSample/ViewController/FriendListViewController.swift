//
//  FriendListViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/20.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit

class FriendListViewController: UIViewController {
    let controllerName = "friend"

    @IBAction func onBtnFriend(sender: AnyObject) {
        transition.to("/top/home#/friend/show_friend")
    }

    
    @IBAction func onBtnHelp(sender: AnyObject) {
        transition.to("/top/home#/friend!help")
    }
}
