//
//  TransitionModel.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import Foundation
import UIKit

private let instance: TransitionGraphModel = TransitionGraphModel()


// Director?
public class TransitionInfo {
    public let commonPath : ViewControllerPath
    public let newComponentList : [ViewControllerGraphProperty]
    public let oldComponentList : [ViewControllerGraphProperty]
    
    public init(commonPath: ViewControllerPath, newComponentList: [ViewControllerGraphProperty], oldComponentList: [ViewControllerGraphProperty])  {
        self.commonPath = commonPath
        self.newComponentList = newComponentList
        self.oldComponentList = oldComponentList
    }
}

public class TransitionGraphModel {
    public class func getInstance() -> TransitionGraphModel {
        return instance
    }
    
    // MARK: Observable
    ///////// Observable ///////////
    public typealias NotificationHandler = (TransitionGraphModel, TransitionInfo) -> Void
    
    private var observers = [(AnyObject, NotificationHandler)]()
    public func addObserver(object: AnyObject, handler: (TransitionGraphModel, TransitionInfo) -> Void) {
        observers.append((object, handler))
    }
    
    public func removeObserver(object: AnyObject) {
        observers = observers.filter { $0.0 !== object}
    }
    
    private func notify(info: TransitionInfo) {
        for observer in observers {
            observer.1(self, info)
        }
    }
    //////////////////////////////////
    
    
    // MARK: Transition
    public var destination : String = "" {
        didSet {
            pastViewControllerPath = viewControllerPath
            viewControllerPath = ViewControllerPath(path: destination)
            let (common, d1, d2) = ViewControllerPath.diff(path1: pastViewControllerPath, path2: viewControllerPath)
            notify(TransitionInfo(commonPath: common, newComponentList: d2, oldComponentList: d1))
        }
    }
    
    public private(set) var viewControllerPath = ViewControllerPath(path: "")
    public private(set) var pastViewControllerPath = ViewControllerPath(path: "")
}


