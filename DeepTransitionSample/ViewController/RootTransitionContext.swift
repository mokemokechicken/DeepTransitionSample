//
//  RootTransitionContext.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/16.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//


import UIKit

public class RootTransitionContext : ViewControllerTransitionContext, HasTransitionContext {
    public var transitionContext : ViewControllerTransitionContext? { return self }

    public init(center: TransitionCenterProtocol) {
        super.init(delegate: nil, center: center)
    }
    
    override public func removeChildViewController() {
        transitionCenter.reportFinishedRemoveViewControllerFrom(self)
    }
    
    override public func addChildViewController(vcInfo: ViewControllerGraphProperty)  {
        let window = UIApplication.sharedApplication().delegate?.window
        switch vcInfo.identifier {
        case "top":
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("top") as UIViewController
            let nav = UINavigationController(rootViewController: vc)
            window??.rootViewController = nav
            window??.makeKeyAndVisible()
            
            transitionCenter.reportAddedViewController(vc)
        default:
            break
        }
    }
    
}
