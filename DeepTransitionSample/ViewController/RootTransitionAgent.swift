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

    class func create() -> RootTransitionAgent {
        return RootTransitionAgent(path: TransitionPath(path: ""))
    }
    
    func start(destinaton: String) {
        transitionCenter.request(destinaton)
    }

    public func decideViewController(pathComponent: TransitionPathComponent) -> UIViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(pathComponent.identifier) as? TransitionViewController
    }

    override public func removeViewController(pathComponent: TransitionPathComponent) {
        transitionCenter.reportFinishedRemoveViewControllerFrom(transitionPath)
    }
    
    override public func addViewController(pathComponent: TransitionPathComponent) -> Bool  {
        let window = UIApplication.sharedApplication().delegate?.window
        let path = transitionPath.appendPath(component: pathComponent)
 
        if let vc = decideViewController(pathComponent) {
            if let transitionVC = vc as? TransitionViewControllerProtocol {
                if pathComponent.ownRootContainer == .Navigation {
                    window??.rootViewController = UINavigationController(rootViewController: vc)
                } else {
                    window??.rootViewController = vc
                }
                window??.makeKeyAndVisible()
                
                transitionVC.setupAgent(path)
                transitionCenter.reportViewDidAppear(path)
                return true
            }
        }
        return false
    }
    
    func forever() -> RootTransitionAgent {
        instance = self
        return self
    }
}
