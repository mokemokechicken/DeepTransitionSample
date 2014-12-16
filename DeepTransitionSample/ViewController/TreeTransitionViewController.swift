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
    let transition = TransitionViewControllerModel.getInstance()
    
    // May Override
    public func removeChildViewController(completionHandler: () -> ()) {
        if let modal = presentedViewController {
            modal.dismissViewControllerAnimated(true, nil)
        }
        
        if let navi = navigationController {
            navi.popToViewController(self, animated: true)
        }
        completionHandler()
    }
    
    // May Override
    public func processInfo(vcInfo: ViewControllerGraphProperty) -> ViewControllerGraphProperty? {
        return vcInfo
    }
    
    public func beforePresentViewController(vc: UIViewController, info: ViewControllerGraphProperty) {
        // for customize animation
    }
    
    // May Override
    public func addChildViewController(info: ViewControllerGraphProperty, completionHandler: (UIViewController?) -> ()) {
        if let vcInfo = processInfo(info) {
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(vcInfo.identifier) as? UIViewController {
                switch vcInfo.segueKind {
                case .Show:
                    self.navigationController?.pushViewController(vc, animated: true) {
                        completionHandler(vc)
                    }
                    
                case .Modal:
                    if vcInfo.ownRootContainer == .Navigation {
                        let nav = UINavigationController(rootViewController: vc)
                        self.presentViewController(nav, animated: true) { completionHandler(vc); return }
                    } else {
                        self.presentViewController(vc, animated: true) { completionHandler(vc); return }
                    }
                    
                case .Tab:
                    // Unimplemented Yet
                    break
                }
            } else {
                completionHandler(nil)
            }
        } else {
            completionHandler(nil)
        }
    }

    // ViewController階層に追加・削除されたタイミングでObserveするようにする
    public override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if self.parentViewController === parent {
            NSLog("\(self.description): Added to ViewControlelr Tree")
        } else {
            NSLog("\(self.description): Removed From ViewControlelr Tree")
        }
    }
}

extension UINavigationController {
    public func pushViewController(viewController: UIViewController, animated: Bool, completion: () -> ()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}



