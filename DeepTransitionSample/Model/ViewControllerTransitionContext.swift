//
//  ViewControllerTransitionContext.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/16.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit


@objc public protocol ViewControllerTransitionContextDelegate {
    var transitionContext: ViewControllerTransitionContext? { get set }
    func removeChildViewController(completionHandler: () -> ())
    func addChildViewController(vcInfo: ViewControllerGraphProperty, completionHandler: (UIViewController?) -> ())

    optional func canDisappearNow() -> Bool
}

@objc public class ViewControllerTransitionContext {
    public private(set) var path: ViewControllerPath!
    public weak var delegate : ViewControllerTransitionContextDelegate?
    
    public init(delegate: ViewControllerTransitionContextDelegate, baseContext: ViewControllerTransitionContext, vcInfo: ViewControllerGraphProperty) {
        self.delegate = delegate
        self.path = baseContext.path.appendPath(vcInfo)
        registerToModel()
    }

    public init(delegate: ViewControllerTransitionContextDelegate?) {
        self.delegate = delegate
        self.path = ViewControllerPath(path: "")
        registerToModel()
    }
    
    public func canDisappearNow(nextPath: ViewControllerPath) -> Bool {
        return del?.canDisappearNow?() ?? true
    }
    
    public func removeChildViewController(completionHandler: () -> ()) {
        if let d = del {
            d.removeChildViewController(completionHandler)
        } else {
            completionHandler()
        }
    }
    
    public func addChildViewController(vcInfo: ViewControllerGraphProperty, completionHandler: (UIViewController?) -> ())  {
        if let d = del {
            d.addChildViewController(vcInfo, completionHandler)
        } else {
            completionHandler(nil)
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
        TransitionViewControllerModel.getInstance().addContext(self)
    }
    
    private func unregisterFromModel() {
        // TODO: Use Locator
        TransitionViewControllerModel.getInstance().removeContext(self)
    }
}


