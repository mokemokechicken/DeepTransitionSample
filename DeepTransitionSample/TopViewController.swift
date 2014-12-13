//
//  TopViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit

class TopViewController: TreeTransitionViewController {
    

    override func viewDidLoad() {
        self.path = "/top"
        self.childs = ["news", "coupon"]
        super.viewDidLoad()
    }
    
    @IBAction func onBtnNews(sender: AnyObject) {
        transition("/top/news/detail?id=10")
    }
    
    @IBAction func onBtnCoupon(sender: AnyObject) {
        transition("/top/coupon")
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
