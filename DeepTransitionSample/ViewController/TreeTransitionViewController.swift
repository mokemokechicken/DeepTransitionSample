//
//  TreeTransitionViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit

class TreeTransitionViewController: UIViewController {
    let transitionModel = TransitionModel.getInstance()
  
}

public protocol ViewControllerGraphProtocol {
    func showViewController(graphInfo: ViewControllerGraphPropertyProtocol)
    func removeAllChildViewControllers()
    func allowToBeRemovedNow() -> Bool
    func didReceiveDissmissRequest()
}

public enum SegueKind : String {
    case Show = "/"
    case Modal = "!"
    case Tab = "#"
}

public protocol ViewControllerGraphPropertyProtocol {
    var identifier : String { get }
    var params : [String:AnyObject] { get set }
    var segueKind: SegueKind { get set }
    var path: String { get set }
    var viewController: UIViewController { get set }
}
