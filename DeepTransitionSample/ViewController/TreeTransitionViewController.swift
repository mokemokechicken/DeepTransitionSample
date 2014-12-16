//
//  TreeTransitionViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit

public class TreeTransitionViewController: UIViewController, ViewControllerGraphProtocol {
    public var viewControllerPath: ViewControllerPath?
    public var viewControllerPropery: ViewControllerGraphProperty? {
        return viewControllerPath?.componentList.last
    }

    // 普通にNAVIなら自分までPOPさせるでOK: NaviCがあって、子供がShowならこれでいいかな。
    // 子供がModalなら子供をDismissさせればOK
    // 子供がTabなら？ 何もしなくて良いはず
    // Swap?
    // Please Override if needed
    public func removeAllChildViewControllers() {
        if let modal = presentedViewController as? DismissableViewController {
            modal.didReceiveDismissRequest()
        } else if let modal = presentedViewController {
            modal.dismissViewControllerAnimated(true, nil)
        }
        
        if let navi = navigationController {
            navi.popToViewController(self, animated: true)
        }
    }
    
    // Please Override
    public func showViewController(vcInfo: ViewControllerGraphProperty) -> ViewControllerGraphProtocol? {
        return nil
    }

    // ViewController階層に追加・削除されたタイミングでObserveするようにする
    public override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        let model = TransitionGraphModel.getInstance()
        if self.parentViewController === parent {
            NSLog("\(self.description): addObserver")
            model.addObserver(self, handler: self.didUpdateTransitionDestination)
        } else {
            NSLog("\(self.description): removeObserver")
            model.removeObserver(self)
        }
    }
    
    public func didUpdateTransitionDestination(model: TransitionGraphModel, info: TransitionInfo) {
        let dest = model.destination
        if let path = viewControllerPath {
            if path == info.commonPath {
                removeAllChildViewControllers()
                if let vcInfo = info.newComponentList.first {
                    showViewController(vcInfo)
                }
            }
        }
    }
}

@objc public protocol ViewControllerTransitionContextDelegate {
    var transitionContext: ViewControllerTransitionContext? { get set }
    func canDisappearNow() -> Bool
    func removeChildViewController(completionHandler: () -> ())
    func addChildViewController(vcInfo: ViewControllerGraphProperty) -> UIViewController
}

@objc public class ViewControllerTransitionContext {
    public private(set) var path: ViewControllerPath?
    public weak var delegate : ViewControllerTransitionContextDelegate?
    
    func setup(baseContext: ViewControllerTransitionContext, vcInfo: ViewControllerGraphProperty) {
        path = baseContext.path?.appendPath(vcInfo)
        registerToModel()
    }

    public func canDisappearNow(nextPath: ViewControllerPath) -> Bool {
        return del?.canDisappearNow() ?? true
    }
    
    public func removeChildViewController(completionHandler: () -> ()) {
        if let d = del {
            d.removeChildViewController(completionHandler)
        } else {
            completionHandler()
        }
    }
    
    public func addChildViewController(vcInfo: ViewControllerGraphProperty) -> UIViewController? {
        var ret = del?.addChildViewController(vcInfo)
        if let hasContext = ret as? ViewControllerTransitionContextDelegate {
            if hasContext.transitionContext  == nil {
                hasContext.transitionContext = ViewControllerTransitionContext()
                hasContext.transitionContext?.setup(self, vcInfo: vcInfo)
            }
        }
        return ret
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
        // TODO
    }
    
    private func unregisterFromModel() {
        // TODO
    }
    
}


@objc public protocol DismissableViewController {
    func didReceiveDismissRequest()
}


@objc public protocol ViewControllerGraphProtocol {
    var viewControllerPath: ViewControllerPath? { get set }
    func showViewController(vcInfo: ViewControllerGraphProperty) -> ViewControllerGraphProtocol?
    func removeAllChildViewControllers()
//    func allowToBeRemovedNow() -> Bool
}


