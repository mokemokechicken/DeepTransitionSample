//
//  TopViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit

public class TopViewController: TreeTransitionViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    @IBAction func onBtnNews(sender: AnyObject) {
        transition.request("/top/list_news")
    }
    
    @IBAction func onBtnCoupon(sender: AnyObject) {
        transition.request("/top/list_coupon")
    }

    
}
