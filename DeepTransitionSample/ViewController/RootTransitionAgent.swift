//
//  RootTransitionContext.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/16.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//


import UIKit

private var instance : RootTransitionAgent?

public class RootTransitionAgent : TransitionAgent, HasTransitionAgent {
    public var transitionAgent : TransitionAgent? { return self }

    public init(center: TransitionCenterProtocol) {
        super.init(delegate: nil, center: center)
    }
    
    override public func removeChildViewController() {
        transitionCenter.reportFinishedRemoveViewControllerFrom(self)
    }
    
    override public func addChildViewController(pathComponent: TransitionPathComponent)  {
        let window = UIApplication.sharedApplication().delegate?.window
        switch pathComponent.identifier {
        case "top":
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("top") as TransitionViewController
            let nav = UINavigationController(rootViewController: vc)
            window??.rootViewController = nav
            window??.makeKeyAndVisible()
            
            setupChildAgent(vc, pathComponent: pathComponent)
            transitionCenter.reportViewDidAppear(vc)

        default:
            break
        }
    }
    
    func forever() -> RootTransitionAgent {
        instance = self
        return self
    }
}
