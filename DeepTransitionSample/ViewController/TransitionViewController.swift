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
    public private(set) var transitionPath : TransitionPath
    private var transitionCenter : TransitionCenterProtocol { return TransitionServiceLocater.transitionCenter }

    public init(viewController: UIViewController?, path: TransitionPath) {
        self.delegate = viewController
        self.transitionPath = path
    }
    
    public func removeChildViewController() {
        if let modal = delegate?.presentedViewController {
            modal.dismissViewControllerAnimated(true, nil)
        }
        
        if let navi = delegate?.navigationController {
            navi.popToViewController(delegate!, animated: true)
        }
        transitionCenter.reportFinishedRemoveViewControllerFrom(transitionPath)
    }
    
    // May Override
    public func addViewController(pathComponent: TransitionPathComponent) {
        if let vc = delegate?.storyboard?.instantiateViewControllerWithIdentifier(pathComponent.identifier) as? UIViewController {
            if let transitionVC = vc as? TransitionViewControllerProtocol {
                
                let newAgent = TransitionAgent(path: transitionPath.appendPath(component: pathComponent))
                let handler = TransitionDefaultHandler(viewController: vc, path: newAgent.transitionPath)
                newAgent.delegate = transitionVC
                newAgent.agentDelegateDefaultImpl = handler
                transitionVC.transitionAgent = newAgent
                
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
        }
        transitionCenter.reportTransitionError("AddViewControlelr: \(pathComponent.identifier)")
    }
    
    deinit {
        NSLog("deinit TransitionHandler: \(self)")
    }
}

public class TransitionViewController: UIViewController, TransitionViewControllerProtocol {
    public var transitionAgent: TransitionAgent?
    public var transitionCenter : TransitionCenterProtocol { return TransitionServiceLocater.transitionCenter }
    
    public func reportViewDidAppear() {
        if let path = transitionAgent?.transitionPath {
            transitionCenter.reportViewDidAppear(path)
        }
    }
    
    public func transition(destination: String) {
        transitionCenter.request(destination)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reportViewDidAppear()
        NSLog("viewDidAppear: \(self)")
    }
    
    deinit {
        NSLog("deinit: \(self.description)")
    }
}

