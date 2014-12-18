//
//  ViewControllerTransitionContext.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/16.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit


@objc public protocol HasTransitionAgent {
    var transitionContext: TransitionAgent? { get }
}

@objc public protocol TransitionAgentDelegate : HasTransitionAgent {
    var transitionContext: TransitionAgent? { get set }
    func addViewController(vcInfo: TransitionPathComponent)

    optional func removeChildViewController()
    optional func canDisappearNow() -> Bool
}

@objc public class TransitionAgent {
    public private(set) var path: TransitionPath!
    public weak var delegate : TransitionAgentDelegate?
    private var vcInfo : TransitionPathComponent?
    let transitionCenter: TransitionCenterProtocol
    
    public var params : [String:String]? {
        return vcInfo?.params
    }
    
    public init(delegate: TransitionAgentDelegate, center: TransitionCenterProtocol, baseContext: TransitionAgent, vcInfo: TransitionPathComponent) {
        self.delegate = delegate
        self.vcInfo = vcInfo
        self.path = baseContext.path.appendPath(component: vcInfo)
        self.transitionCenter = center
        transitionCenter.addContext(self)
    }

    public init(delegate: TransitionAgentDelegate?, center: TransitionCenterProtocol) {
        self.delegate = delegate
        self.path = TransitionPath(path: "")
        self.transitionCenter = center
        transitionCenter.addContext(self)
    }
    
    public func setupContext(delegate: TransitionAgentDelegate, vcInfo: TransitionPathComponent) {
        delegate.transitionContext = TransitionAgent(delegate: delegate, center: transitionCenter, baseContext: self, vcInfo: vcInfo)
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
    
    public func addChildViewController(vcInfo: TransitionPathComponent)  {
        if let d = delegate {
            d.addViewController(vcInfo)
        } else {
            // TODO: Use DEFAULT Implementatin
        }
    }
    
    // MARK: Private
    
    deinit {
        NSLog("deinit Context: \(self.path)")
    }
}


