//
//  ViewControllerTransitionContext.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/16.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit


@objc public protocol OwnTransitionAgent {
    var transitionAgent: TransitionAgentProtocol? { get set }
}

@objc public protocol TransitionAgentDelegate {
    optional func addViewController(pathComponent: TransitionPathComponent) -> Bool
    optional func removeViewController(pathComponent: TransitionPathComponent)
    optional func canDisappearNow(nextPath: TransitionPath) -> Bool
    
    // Customize Show Child ViewController
    optional func decideViewController(pathComponent: TransitionPathComponent)  -> UIViewController?
    optional func showViewController(vc: UIViewController, pathComponent: TransitionPathComponent) -> Bool
    optional func showModalViewController(vc: UIViewController, pathComponent: TransitionPathComponent) -> Bool
    optional func showInternalViewController(vc: UIViewController, pathComponent: TransitionPathComponent) -> Bool
}

@objc public protocol TransitionViewControllerProtocol : TransitionAgentDelegate, OwnTransitionAgent {
     func setupAgent(path: TransitionPath)
}

@objc public protocol TransitionAgentProtocol {
    var transitionPath : TransitionPath { get }
    var params : [String:String]? { get}
    var delegate : TransitionAgentDelegate? { get set }
    var delegateDefaultImpl : TransitionAgentDelegate? { get set }

    func addViewController(pathComponent: TransitionPathComponent) -> Bool
    func removeViewController(pathComponent: TransitionPathComponent)
    func canDisappearNow(nextPath: TransitionPath) -> Bool
}

@objc public class TransitionAgent : TransitionAgentProtocol {
    public private(set) var transitionPath: TransitionPath
    public var params : [String:String]? {
        return pathComponent?.params
    }
    
    public weak var delegate : TransitionAgentDelegate?
    public var delegateDefaultImpl : TransitionAgentDelegate?

    private var pathComponent: TransitionPathComponent?
    var transitionCenter: TransitionCenterProtocol { return TransitionServiceLocater.transitionCenter }
    

    public init(path: TransitionPath) {
        self.pathComponent = path.componentList.last
        self.transitionPath = path
        transitionCenter.addAgent(self)
    }

    public convenience init(parentAgent: TransitionAgentProtocol, pathComponent: TransitionPathComponent) {
        self.init(path: parentAgent.transitionPath.appendPath(component: pathComponent))
    }
    
    //
    public func canDisappearNow(nextPath: TransitionPath) -> Bool {
        return delegate?.canDisappearNow?(nextPath) ?? delegateDefaultImpl?.canDisappearNow?(nextPath) ?? true
    }

    public func removeViewController(pathComponent: TransitionPathComponent) {
        if let handler = delegate?.removeViewController {
            handler(pathComponent)
        } else if let handler = delegateDefaultImpl?.removeViewController  {
            handler(pathComponent)
        } else {
            transitionCenter.reportTransitionError("No Remove Child Handler")
        }
    }
    
    public func addViewController(pathComponent: TransitionPathComponent) -> Bool {
        if let handler = delegate?.addViewController {
            return handler(pathComponent)
        } else if let handler = delegateDefaultImpl?.addViewController {
            return handler(pathComponent)
        } else {
            return false
        }
    }
    
    // MARK: Private
    
    deinit {
        NSLog("deinit Agent: \(self.transitionPath)")
    }
}


