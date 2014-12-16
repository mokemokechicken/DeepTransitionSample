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
        transition.request("/top/list_news/show_news(id=44)")
    }

    @IBAction func onBtnNews2(sender: AnyObject) {
        transition.request("/top/list_news!show_news(id=44)")
    }

}
