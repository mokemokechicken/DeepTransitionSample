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
    public func addViewController(pathComponent: TransitionPathComponent) -> Bool {
        if let vc = delegate?.storyboard?.instantiateViewControllerWithIdentifier(pathComponent.identifier) as? UIViewController {
            if let transitionVC = vc as? TransitionViewControllerProtocol {
                transitionVC.setupAgent(transitionPath.appendPath(component: pathComponent))
                
                switch pathComponent.segueKind {
                case .Show:
                    delegate!.navigationController?.pushViewController(vc, animated: true)
                    return true
                    
                case .Modal:
                    if pathComponent.ownRootContainer == .Navigation {
                        let nav = UINavigationController(rootViewController: vc)
                        delegate!.presentViewController(nav, animated: true) {}
                    } else {
                        delegate!.presentViewController(vc, animated: true) {}
                    }
                    return true
                    
                case .Tab:
                    // Unimplemented Yet
                    break
                }
                
            }
        }
        return false
    }
    
    deinit {
        NSLog("deinit TransitionHandler: \(self)")
    }
}

public class TransitionViewController: UIViewController, TransitionViewControllerProtocol {
    public var transitionAgent: TransitionAgentProtocol?
    public var transitionCenter : TransitionCenterProtocol { return TransitionServiceLocater.transitionCenter }
    private var missReporting = false
    
    public func reportViewDidAppear() {
        if let path = transitionAgent?.transitionPath {
            transitionCenter.reportViewDidAppear(path)
            missReporting = false
        } else {
            missReporting = true
        }
    }
    
    public func requestTransition(destination: String) {
        transitionCenter.request(destination)
    }
    
    public func setupAgent(path: TransitionPath) {
        transitionAgent = TransitionAgent(path: path)
        transitionAgent!.delegate = self
        transitionAgent!.delegateDefaultImpl = TransitionDefaultHandler(viewController: self, path: path)
        if missReporting {
            reportViewDidAppear()
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reportViewDidAppear()
        NSLog("viewDidAppear: \(self)")
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        missReporting = false
    }
    
    deinit {
        NSLog("deinit: \(self.description)")
    }
}

