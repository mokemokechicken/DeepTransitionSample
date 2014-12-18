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
    optional func removeChildViewController()
    optional func canDisappearNow(nextPath: TransitionPath) -> Bool
}

@objc public protocol TransitionViewControllerProtocol : TransitionAgentDelegate, OwnTransitionAgent {
     func setupAgent(path: TransitionPath)
}

@objc public protocol TransitionAgentProtocol {
    var transitionPath : TransitionPath { get }
    var params : [String:String]? { get}
    var delegate : TransitionAgentDelegate? { get set }
    var delegateDefaultImpl : TransitionAgentDelegate? { get set }

    func addChildViewController(pathComponent: TransitionPathComponent) -> Bool
    func removeChildViewController()
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

    public func removeChildViewController() {
        if let handler = delegate?.removeChildViewController {
            handler()
        } else if let handler = delegateDefaultImpl?.removeChildViewController? {
            handler()
        } else {
            transitionCenter.reportTransitionError("No Remove Child Handler")
        }
    }
    
    public func addChildViewController(pathComponent: TransitionPathComponent) -> Bool {
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


