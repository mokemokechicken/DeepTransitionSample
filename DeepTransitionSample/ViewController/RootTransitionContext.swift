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
//        UIApplication.sharedApplication().delegate?.window??.rootViewController = nil
        completionHandler()
    }
    
    override public func addChildViewController(vcInfo: ViewControllerGraphProperty, completionHandler: (UIViewController?) -> ())  {
        let window = UIApplication.sharedApplication().delegate?.window
        switch vcInfo.identifier {
        case "top":
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("top") as UIViewController
            let nav = UINavigationController(rootViewController: vc)
            window??.rootViewController = nav
            window??.makeKeyAndVisible()
            
            completionHandler(vc)
        default:
            break
        }
    }
    
}
