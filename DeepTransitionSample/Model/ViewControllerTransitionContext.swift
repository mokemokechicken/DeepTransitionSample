//
//  ViewControllerTransitionContext.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/16.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit


@objc public protocol HasTransitionContext {
    var transitionContext: ViewControllerTransitionContext? { get }
}

@objc public protocol ViewControllerTransitionContextDelegate : HasTransitionContext {
    var transitionContext: ViewControllerTransitionContext? { get set }
    func addViewController(vcInfo: ViewControllerGraphProperty)

    optional func removeChildViewController()
    optional func canDisappearNow() -> Bool
}

@objc public class ViewControllerTransitionContext {
    public private(set) var path: ViewControllerPath!
    public weak var delegate : ViewControllerTransitionContextDelegate?
    private var vcInfo : ViewControllerGraphProperty?
    let transitionCenter: TransitionCenterProtocol
    
    public var params : [String:String]? {
        return vcInfo?.params
    }
    
    public init(delegate: ViewControllerTransitionContextDelegate, center: TransitionCenterProtocol, baseContext: ViewControllerTransitionContext, vcInfo: ViewControllerGraphProperty) {
        self.delegate = delegate
        self.vcInfo = vcInfo
        self.path = baseContext.path.appendPath(component: vcInfo)
        self.transitionCenter = center
        registerToModel()
    }

    public init(delegate: ViewControllerTransitionContextDelegate?, center: TransitionCenterProtocol) {
        self.delegate = delegate
        self.path = ViewControllerPath(path: "")
        self.transitionCenter = center
        registerToModel()
    }
    
    //
    public func canDisappearNow(nextPath: ViewControllerPath) -> Bool {
        return del?.canDisappearNow?() ?? true
    }

    public func removeChildViewController() {
        if let handler = del?.removeChildViewController {
            handler()
        } else {
            transitionCenter.reportFinishedRemoveViewControllerFrom(del)
        }
    }
    
    public func addChildViewController(vcInfo: ViewControllerGraphProperty)  {
        if let d = del {
            d.addViewController(vcInfo)
        } else {
            transitionCenter.reportAddedViewController(nil)
        }
    }
    
    // MARK: Private
    private var del : ViewControllerTransitionContextDelegate? {
        if let del = self.delegate {
            return del
        } else {
            unregisterFromModel()
            return nil
        }
    }
    
    private func registerToModel() {
        // TODO: Use Locator
        transitionCenter.addContext(self)
    }
    
    private func unregisterFromModel() {
        // TODO: Use Locator
        transitionCenter.removeContext(self)
    }
}


