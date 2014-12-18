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
    
    public func removeViewController(pathComponent: TransitionPathComponent) {
        if let modal = delegate?.presentedViewController {
            modal.dismissViewControllerAnimated(true, nil)
        }
        
        if let navi = delegate?.navigationController {
            navi.popToViewController(delegate!, animated: true)
        }
        transitionCenter.reportFinishedRemoveViewControllerFrom(transitionPath)
    }
    
    public func decideViewController(pathComponent: TransitionPathComponent) -> UIViewController? {
        if let handler = (delegate as? TransitionAgentDelegate)?.decideViewController {
            return handler(pathComponent)
        } else {
            return delegate?.storyboard?.instantiateViewControllerWithIdentifier(pathComponent.identifier) as? UIViewController
        }
    }
    
    public func showViewController(vc: UIViewController, pathComponent: TransitionPathComponent) -> Bool {
        if let handler = (delegate as? TransitionAgentDelegate)?.showViewController {
            return handler(vc, pathComponent: pathComponent)
        } else {
            return (delegate!.navigationController?.pushViewController(vc, animated: true)) != nil
        }
    }
    
    public func showModalViewController(vc: UIViewController, pathComponent: TransitionPathComponent) -> Bool {
        if let handler = (delegate as? TransitionAgentDelegate)?.showModalViewController {
            return handler(vc, pathComponent: pathComponent)
        } else {
            if pathComponent.ownRootContainer == .Navigation {
                let nav = UINavigationController(rootViewController: vc)
                delegate!.presentViewController(nav, animated: true) {}
            } else {
                delegate!.presentViewController(vc, animated: true) {}
            }
            return true
        }
        
    }
    
    public func showInternalViewController(vc: UIViewController, pathComponent: TransitionPathComponent) -> Bool {
        if let handler = (delegate as? TransitionAgentDelegate)?.showInternalViewController {
            return handler(vc, pathComponent: pathComponent)
        } else {
            return false
        }
    }
    
    public func addViewController(pathComponent: TransitionPathComponent) -> Bool {
        if let vc = decideViewController(pathComponent) {
            if let transitionVC = vc as? TransitionViewControllerProtocol {
                transitionVC.setupAgent(transitionPath.appendPath(component: pathComponent))
                
                switch pathComponent.segueKind {
                case .Show:
                    return showViewController(vc, pathComponent: pathComponent)
                    
                case .Modal:
                    return showModalViewController(vc, pathComponent: pathComponent)
                    
                case .Tab:
                    return showInternalViewController(vc, pathComponent: pathComponent)
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

