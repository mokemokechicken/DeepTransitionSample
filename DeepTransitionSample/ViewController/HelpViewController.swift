//
//  HelpViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/20.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBAction func onBtnFriend(sender: AnyObject) {
        transition.to("^/top/home#friend/show_friend")
    }
    
}
