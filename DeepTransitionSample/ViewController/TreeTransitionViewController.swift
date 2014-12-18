//
//  TreeTransitionViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import Foundation
import UIKit

public class TreeTransitionViewController: UIViewController, ViewControllerTransitionContextDelegate {
    public var transitionContext: ViewControllerTransitionContext?
    public var transitionCenter : TransitionCenterProtocol  = TransitionViewControllerModel.getInstance()
    
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
    public func processInfo(vcInfo: ViewControllerGraphProperty) -> ViewControllerGraphProperty? {
        return vcInfo
    }
    
    public func beforePresentViewController(vc: UIViewController, info: ViewControllerGraphProperty) {
        // for customize animation
    }
    
    // May Override
    public func addViewController(vcInfo: ViewControllerGraphProperty) {
        if let info = processInfo(vcInfo) {
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(info.identifier) as? TreeTransitionViewController {
                transitionContext?.setupContext(vc, vcInfo: vcInfo)
                switch vcInfo.segueKind {
                case .Show:
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                    
                case .Modal:
                    if vcInfo.ownRootContainer == .Navigation {
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
        transitionCenter.reportTransitionError("AddViewControlelr: \(vcInfo.identifier)")
    }
    
    deinit {
        NSLog("deinit: \(self.description)")
    }
}

