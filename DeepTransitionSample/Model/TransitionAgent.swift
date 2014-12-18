//
//  ViewControllerTransitionContext.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/16.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit


@objc public protocol HasTransitionAgent {
    var transitionAgent: TransitionAgent? { get }
}

@objc public protocol CanSetTransitionAgent : HasTransitionAgent {
    var transitionAgent: TransitionAgent? { get set }
}

@objc public protocol TransitionAgentDelegate {
    optional func addViewController(vcInfo: TransitionPathComponent)
    optional func removeChildViewController()
    optional func canDisappearNow() -> Bool
}

@objc public class TransitionAgent {
    public private(set) var path: TransitionPath!
    public weak var delegate : TransitionAgentDelegate?
    public var agentDelegateDefaultImpl : TransitionAgentDelegate?
    private var pathComponent: TransitionPathComponent?
    let transitionCenter: TransitionCenterProtocol
    
    
    public var params : [String:String]? {
        return pathComponent?.params
    }

    public init(delegate: TransitionAgentDelegate, center: TransitionCenterProtocol, path: TransitionPath) {
        self.delegate = delegate
        self.pathComponent = path.componentList.last
        self.path = path
        self.transitionCenter = center
        transitionCenter.addAgent(self)
    }

    public convenience init(delegate: TransitionAgentDelegate, center: TransitionCenterProtocol, parentAgent: TransitionAgent, pathComponent: TransitionPathComponent) {
        self.init(delegate: delegate, center: center, path: parentAgent.path.appendPath(component: pathComponent))
    }

    public init(center: TransitionCenterProtocol) {
        self.path = TransitionPath(path: "")
        self.transitionCenter = center
        transitionCenter.addAgent(self)
    }

    public func setupChildAgent(target: protocol<TransitionAgentDelegate,CanSetTransitionAgent>, pathComponent: TransitionPathComponent) {
        target.transitionAgent = TransitionAgent(delegate: target, center: transitionCenter, parentAgent: self, pathComponent: pathComponent)
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
        NSLog("deinit Context: \(self.path)")
    }
}


