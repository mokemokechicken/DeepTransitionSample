//
//  CouponListViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit

class CouponListViewController: TransitionViewController {
    @IBAction func onBtnCoupon2(sender: AnyObject) {
        requestTransition("/top!/list_coupon/show_coupon(id=99)")
    }
    @IBAction func onBtnNews2(sender: AnyObject) {
        requestTransition("/top!/list_coupon/show_news(id=99)")
    }
}
