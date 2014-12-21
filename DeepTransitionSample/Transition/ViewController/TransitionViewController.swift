//
//  TreeTransitionViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol HasControllerName {
    optional var controllerName : String { get }
}

public class TransitionDefaultHandler : TransitionAgentDelegate {
    private weak var delegate : UIViewController?
    public private(set) var transitionPath : TransitionPath
    private var transition : TransitionCenterProtocol { return TransitionServiceLocater.transitionCenter }

    public init(viewController: UIViewController?, path: TransitionPath) {
        self.delegate = viewController
        self.transitionPath = path
    }
    
    public func removeViewController(pathComponent: TransitionPathComponent) -> Bool {
        if let modal = delegate?.presentedViewController {
            modal.dismissViewControllerAnimated(true, nil)
        }
        
        if let navi = delegate?.navigationController {
            navi.popToViewController(delegate!, animated: true)
        }
        
        transition.reportFinishedRemoveViewControllerFrom(transitionPath)
        return true
    }
    
    public func decideViewController(pathComponent: TransitionPathComponent) -> UIViewController? {
        if let handler = (delegate as? TransitionAgentDelegate)?.decideViewController {
            return handler(pathComponent)
        } else {
            switch delegate? {
            case let .Some(tab as UITabBarController):
                var innerVC = tab.findViewControllerInCollection(pathComponent.identifier)
                return innerVC?.vc

            default:
                return delegate?.storyboard?.instantiateViewControllerWithIdentifier(pathComponent.identifier) as? UIViewController
            }
        }
    }
    
    public func showViewController(vc: UIViewController, pathComponent: TransitionPathComponent) -> Bool {
        if let handler = (delegate as? TransitionAgentDelegate)?.showViewController {
            return handler(vc, pathComponent: pathComponent)
        } else {
            return (delegate?.navigationController?.pushViewController(vc, animated: true)) != nil
        }
    }
    
    public func showModalViewController(vc: UIViewController, pathComponent: TransitionPathComponent) -> Bool {
        if let handler = (delegate as? TransitionAgentDelegate)?.showModalViewController {
            return handler(vc, pathComponent: pathComponent)
        } else {
            if pathComponent.ownRootContainer == .Navigation {
                let nav = UINavigationController(rootViewController: vc)
                delegate?.presentViewController(nav, animated: true) {}
            } else {
                delegate?.presentViewController(vc, animated: true) {}
            }
            return true
        }
    }
    
    public func showInternalViewController(vc: UIViewController, pathComponent: TransitionPathComponent) -> Bool {
        if let handler = (delegate as? TransitionAgentDelegate)?.showInternalViewController {
            return handler(vc, pathComponent: pathComponent)
        } else {
            switch delegate? {
            case let .Some(tab as UITabBarController):
                if let innerVC = tab.findViewControllerInCollection(pathComponent.identifier) {
                    tab.selectedIndex = innerVC.index
                    innerVC.vc.reportViewDidAppear()
                    return true
                }
            default:
                break
            }
        }
        return false
    }
    
    public func addViewController(pathComponent: TransitionPathComponent) -> Bool {
        if let vc = decideViewController(pathComponent) {
            vc.setupAgent(transitionPath.appendPath(component: pathComponent))
            
            switch pathComponent.segueKind {
            case .Show:
                return showViewController(vc, pathComponent: pathComponent)
                
            case .Modal:
                return showModalViewController(vc, pathComponent: pathComponent)
                
            case .Tab:
                return showInternalViewController(vc, pathComponent: pathComponent)
            }
        }
        return false
    }
    
}

private var transitionAgentKey: UInt8 = 0

extension UIViewController : TransitionViewControllerProtocol, HasControllerName {
    public var transition : TransitionCenterProtocol { return TransitionServiceLocater.transitionCenter }
    public var transitionAgent: TransitionAgentProtocol? {
        get {
            return objc_getAssociatedObject(self, &transitionAgentKey) as? TransitionAgentProtocol
        }
        set {
            objc_setAssociatedObject(self, &transitionAgentKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    public func setupAgent(path: TransitionPath) {
        if self.transitionAgent?.transitionPath == path {
            return
        }

        transitionAgent = createTransitionAgent(path)
        transitionAgent!.delegate = self
        if transitionAgent!.delegateDefaultImpl == nil {
            transitionAgent!.delegateDefaultImpl = createTransitionDefaultHandler(path)
        }
    }
    
    public func viewDidAppear(animated: Bool) {
        reportViewDidAppear()
        mylog("viewDidAppear: \(self)")
    }

    public func reportViewDidAppear() {
        if let path = transitionAgent?.transitionPath {
            transition.reportViewDidAppear(path)
        }
    }
    
    public func createTransitionAgent(path: TransitionPath) -> TransitionAgentProtocol {
        return TransitionAgent(path: path)
    }
    
    public func createTransitionDefaultHandler(path: TransitionPath) -> TransitionAgentDelegate {
        return TransitionDefaultHandler(viewController: self, path: path)
    }
    
    public func getControllerName() -> String? {
        return (self as HasControllerName).controllerName
    }
}

private struct ViewControllerInContainer {
    let index : Int
    let name : String?
    let vc : UIViewController
}

extension UITabBarController {
    public func findViewControllerInCollection(name: String) -> (index: Int, vc: UIViewController)? {
        for vcInfo in rootViewControllersInCollection() {
            if vcInfo.name == name {
                return (index: vcInfo.index, vc: vcInfo.vc)
            }
        }
        return nil
    }
    
    public func setupAgentToInnerNameController() {
        if let path = self.transitionAgent?.transitionPath {
            for vcInfo in rootViewControllersInCollection() {
                if let name = vcInfo.name {
                    vcInfo.vc.setupAgent(path.appendPath(TransitionPath(path: "#\(name)")))
                }
            }
        }
    }

    override public func viewDidAppear(animated: Bool) {
        setupAgentToInnerNameController()
        super.viewDidAppear(animated)
    }

    private func findNotContainerViewController(vc: UIViewController!) -> UIViewController? {
        if vc == nil {
            return vc
        }
        
        switch vc {
        case let (nav as UINavigationController):
            return findNotContainerViewController(nav.viewControllers?.first as? UIViewController)
            
        default:
            return vc
        }
        
    }
    
    private func rootViewControllersInCollection() -> [ViewControllerInContainer] {
        var ret = [ViewControllerInContainer]()
        var index = 0
        for innerVC in viewControllers as? [UIViewController] ?? [] {
            if let vc = findNotContainerViewController(innerVC) {
                ret.append(ViewControllerInContainer(index: index, name: vc.getControllerName(), vc: vc))
            }
            index++
        }
        return ret
    }
    
}

private func mylog(s: String) {
#if DEBUG
    NSLog(s)
#endif
}
