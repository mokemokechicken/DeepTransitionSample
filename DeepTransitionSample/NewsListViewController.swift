//
//  NewsListViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit

class NewsListViewController: TreeTransitionViewController {
    @IBAction func onBtnNews1(sender: AnyObject) {
        transition("/top/news/detail?id=1")
    }

    override func viewDidLoad() {
        self.path = "/top/news"
        self.childs = ["detail"]
        super.viewDidLoad()
    }
}
