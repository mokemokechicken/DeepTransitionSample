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

@objc public protocol TransitionAgentDelegate : HasTransitionAgent {
    var transitionAgent: TransitionAgent? { get set }
    func addViewController(vcInfo: TransitionPathComponent)

    optional func removeChildViewController()
    optional func canDisappearNow() -> Bool
}

@objc public class TransitionAgent {
    public private(set) var path: TransitionPath!
    public weak var delegate : TransitionAgentDelegate?
    private var pathComponent: TransitionPathComponent?
    let transitionCenter: TransitionCenterProtocol
    
    public var params : [String:String]? {
        return pathComponent?.params
    }
    
    public init(delegate: TransitionAgentDelegate, center: TransitionCenterProtocol, parentAgent: TransitionAgent, pathComponent: TransitionPathComponent) {
        self.delegate = delegate
        self.pathComponent = pathComponent
        self.path = parentAgent.path.appendPath(component: pathComponent)
        self.transitionCenter = center
        transitionCenter.addContext(self)
    }

    public init(delegate: TransitionAgentDelegate?, center: TransitionCenterProtocol) {
        self.delegate = delegate
        self.path = TransitionPath(path: "")
        self.transitionCenter = center
        transitionCenter.addContext(self)
    }
    
    public func setupChildAgent(target: TransitionAgentDelegate, pathComponent: TransitionPathComponent) {
        target.transitionAgent = TransitionAgent(delegate: target, center: transitionCenter, parentAgent: self, pathComponent: pathComponent)
    }
    
    //
    public func canDisappearNow(nextPath: TransitionPath) -> Bool {
        return delegate?.canDisappearNow?() ?? true
    }

    public func removeChildViewController() {
        if let handler = delegate?.removeChildViewController {
            handler()
        } else {
            // TODO: Use DEFAULT Implementatin
        }
    }
    
    public func addChildViewController(pathComponent: TransitionPathComponent)  {
        if let d = delegate {
            d.addViewController(pathComponent)
        } else {
            // TODO: Use DEFAULT Implementatin
        }
    }
    
    // MARK: Private
    
    deinit {
        NSLog("deinit Context: \(self.path)")
    }
}


