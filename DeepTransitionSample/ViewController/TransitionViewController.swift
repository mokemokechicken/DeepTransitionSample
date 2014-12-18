//
//  TreeTransitionViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import Foundation
import UIKit

public class TransitionViewController: UIViewController, TransitionAgentDelegate {
    public var transitionAgent: TransitionAgent?
    public var transitionCenter : TransitionCenterProtocol  = TransitionCenter.getInstance()
    
    public func transition(destination: String) {
        transitionCenter.request(destination)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        transitionCenter.reportViewDidAppear(self)
        NSLog("viewDidAppear: \(self)")
    }
    
    // May Override
    public func removeChildViewController() {
        if let modal = presentedViewController {
            modal.dismissViewControllerAnimated(true, nil)
        }
        
        if let navi = navigationController {
            navi.popToViewController(self, animated: true)
        }
        transitionCenter.reportFinishedRemoveViewControllerFrom(self)
    }
    
    // May Override
    public func processPathComponent(pathComponent: TransitionPathComponent) -> TransitionPathComponent? {
        return pathComponent
    }
    
    public func beforePresentViewController(vc: UIViewController, info: TransitionPathComponent) {
        // for customize animation
    }
    
    // May Override
    public func addViewController(pathComponent: TransitionPathComponent) {
        if let info = processPathComponent(pathComponent) {
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(info.identifier) as? TransitionViewController {
                transitionAgent?.setupChildAgent(vc, pathComponent: pathComponent)
                switch pathComponent.segueKind {
                case .Show:
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                    
                case .Modal:
                    if pathComponent.ownRootContainer == .Navigation {
                        let nav = UINavigationController(rootViewController: vc)
                        self.presentViewController(nav, animated: true) {}
                    } else {
                        self.presentViewController(vc, animated: true) {}
                    }
                    return
                    
                case .Tab:
                    // Unimplemented Yet
                    break
                }
            }
        }
        transitionCenter.reportTransitionError("AddViewControlelr: \(pathComponent.identifier)")
    }
    
    deinit {
        NSLog("deinit: \(self.description)")
    }
}

