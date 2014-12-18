//
//  ViewControllerTransitionContext.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/16.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit


@objc public protocol OwnTransitionAgent {
    var transitionAgent: TransitionAgent? { get set }
}

@objc public protocol TransitionAgentDelegate {
    optional func addViewController(vcInfo: TransitionPathComponent)
    optional func removeChildViewController()
    optional func canDisappearNow() -> Bool
}

@objc public protocol TransitionViewControllerProtocol : TransitionAgentDelegate, OwnTransitionAgent {}

@objc public class TransitionAgent {
    public private(set) var transitionPath: TransitionPath
    public var params : [String:String]? {
        return pathComponent?.params
    }
    
    public weak var delegate : TransitionAgentDelegate?
    public var agentDelegateDefaultImpl : TransitionAgentDelegate?

    private var pathComponent: TransitionPathComponent?
    var transitionCenter: TransitionCenterProtocol { return TransitionServiceLocater.transitionCenter }
    

    public init(path: TransitionPath) {
        self.pathComponent = path.componentList.last
        self.transitionPath = path
        transitionCenter.addAgent(self)
    }

    public convenience init(parentAgent: TransitionAgent, pathComponent: TransitionPathComponent) {
        self.init(path: parentAgent.transitionPath.appendPath(component: pathComponent))
    }
    
    //
    public func canDisappearNow(nextPath: TransitionPath) -> Bool {
        return delegate?.canDisappearNow?() ?? agentDelegateDefaultImpl?.canDisappearNow?() ?? true
    }

    public func removeChildViewController() {
        if let handler = delegate?.removeChildViewController {
            handler()
        } else if let handler = agentDelegateDefaultImpl?.removeChildViewController? {
            handler()
        } else {
            transitionCenter.reportTransitionError("No Remove Child Handler")
        }
    }
    
    public func addChildViewController(pathComponent: TransitionPathComponent)  {
        if let handler = delegate?.addViewController {
            handler(pathComponent)
        } else if let handler = agentDelegateDefaultImpl?.addViewController {
            handler(pathComponent)
        } else {
            transitionCenter.reportTransitionError("No Add Child Handler")
        }
    }
    
    // MARK: Private
    
    deinit {
        NSLog("deinit Agent: \(self.transitionPath)")
    }
}


