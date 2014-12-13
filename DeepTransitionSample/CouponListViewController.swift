//
//  CouponListViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit

class CouponListViewController: TreeTransitionViewController {
    override func viewDidLoad() {
        self.path = "/top/coupon"
        self.childs = ["detail"]
        super.viewDidLoad()
    }
}
