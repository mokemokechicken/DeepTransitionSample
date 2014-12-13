//
//  NewsViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit

class NewsViewController: TreeTransitionViewController {

    @IBAction func onBtnCoupon2(sender: AnyObject) {
        transition("/top/coupon/detail?id=2")
    }
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        self.path = "/top/news/detail"
        super.viewDidLoad()
    }
}
