//
//  RootTransitionContext.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/16.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//


import UIKit

private var instance : RootTransitionAgent?

public class RootTransitionAgent : TransitionAgent {

    override public func removeChildViewController() {
        transitionCenter.reportFinishedRemoveViewControllerFrom(transitionPath)
    }
    
    override public func addChildViewController(pathComponent: TransitionPathComponent)  {
        let window = UIApplication.sharedApplication().delegate?.window
        let path = transitionPath.appendPath(component: pathComponent)
 
        switch pathComponent.identifier {
        case "top":
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("top") as TransitionViewController
            let nav = UINavigationController(rootViewController: vc)
            window??.rootViewController = nav
            window??.makeKeyAndVisible()

            vc.setupAgent(path)
            transitionCenter.reportViewDidAppear(path)

        default:
            break
        }
    }
    
    func forever() -> RootTransitionAgent {
        instance = self
        return self
    }
}
