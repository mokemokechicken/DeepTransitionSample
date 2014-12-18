//
//  TopViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit

public class TopViewController: TransitionViewController {

    @IBAction func onBtnNews(sender: AnyObject) {
        transition("/top/list_news")
    }
    
    @IBAction func onBtnCoupon(sender: AnyObject) {
        transition("/top!/list_coupon")
    }

    
}
