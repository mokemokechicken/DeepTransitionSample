//
//  TreeTransitionViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit

public class TreeTransitionViewController: UIViewController {

    public override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        let model = TransitionGraphModel.getInstance()
        if self.parentViewController === parent {
            model.addObserver(self, handler: self.didUpdateTransitionDestination)
        } else {
            model.removeObserver(self)
        }
    }
    
    func didUpdateTransitionDestination(model: TransitionGraphModel, info: TransitionGraphModel.TransitionInfo) {
        let dest = model.destination
        
    }
    
}


public protocol ViewControllerGraphProtocol {
    func showViewController(graphInfo: ViewControllerGraphProperty)
    func removeAllChildViewControllers()
    func allowToBeRemovedNow() -> Bool
    func didReceiveDissmissRequest()
}


