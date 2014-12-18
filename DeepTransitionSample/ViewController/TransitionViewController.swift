//
//  TreeTransitionViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import Foundation
import UIKit

public class TransitionDefaultHandler : TransitionAgentDelegate {
    private weak var delegate : UIViewController?
    private let transitionCenter : TransitionCenterProtocol

    public init(viewController: UIViewController?, center: TransitionCenterProtocol) {
        self.delegate = viewController
        self.transitionCenter = center
    }
    
    private func hasAgent() -> HasTransitionAgent? {
        return delegate as? HasTransitionAgent
    }
    
    public func removeChildViewController() {
        if let modal = delegate?.presentedViewController {
            modal.dismissViewControllerAnimated(true, nil)
        }
        
        if let navi = delegate?.navigationController {
            navi.popToViewController(delegate!, animated: true)
        }
        transitionCenter.reportFinishedRemoveViewControllerFrom(hasAgent())
    }
    
    public func setupChildAgent(vc: protocol<TransitionAgentDelegate,CanSetTransitionAgent>, pathComponent: TransitionPathComponent) {
        if let hasAgent = self.delegate as? HasTransitionAgent {
            hasAgent.transitionAgent?.setupChildAgent(vc, pathComponent: pathComponent)
        }
    }
    
    // May Override
    public func addViewController(pathComponent: TransitionPathComponent) {
        if let vc = delegate?.storyboard?.instantiateViewControllerWithIdentifier(pathComponent.identifier) as? TransitionViewController {
            setupChildAgent(vc, pathComponent: pathComponent)
            switch pathComponent.segueKind {
            case .Show:
                delegate!.navigationController?.pushViewController(vc, animated: true)
                return
                
            case .Modal:
                if pathComponent.ownRootContainer == .Navigation {
                    let nav = UINavigationController(rootViewController: vc)
                    delegate!.presentViewController(nav, animated: true) {}
                } else {
                    delegate!.presentViewController(vc, animated: true) {}
                }
                return
                
            case .Tab:
                // Unimplemented Yet
                break
            }
        }
        transitionCenter.reportTransitionError("AddViewControlelr: \(pathComponent.identifier)")
    }
    
    deinit {
        NSLog("deinit TransitionHandler: \(self)")
    }
}

public class TransitionViewController: UIViewController, TransitionAgentDelegate, CanSetTransitionAgent {
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
    
    deinit {
        NSLog("deinit: \(self.description)")
    }
}

