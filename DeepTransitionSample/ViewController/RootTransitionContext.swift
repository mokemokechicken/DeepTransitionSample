//
//  RootTransitionContext.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/16.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//


import UIKit

public class RootTransitionContext : ViewControllerTransitionContext {
    public init() {
        super.init(delegate: nil)
    }
    
    override public func removeChildViewController(completionHandler: () -> ()) {
        UIApplication.sharedApplication().delegate?.window??.rootViewController = nil
        completionHandler()
    }
    
    override public func addChildViewController(vcInfo: ViewControllerGraphProperty, completionHandler: (UIViewController?) -> ())  {
        switch vcInfo.identifier {
        case "top":
            let vc = TopViewController()
            let nav = UINavigationController(rootViewController: vc)
            UIApplication.sharedApplication().delegate?.window??.rootViewController = nav
            completionHandler(vc)
        default:
            break
        }
    }
    
}
