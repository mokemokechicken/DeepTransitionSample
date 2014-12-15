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


public class TransitionGraphModel {
    public class func getInstance() -> TransitionGraphModel {
        return instance
    }
    
    // MARK: Observable
    ///////// Observable ///////////
    public typealias NotificationHandler = (TransitionGraphModel) -> Void
    
    private var observers = [(AnyObject, NotificationHandler)]()
    public func addObserver(object: AnyObject, handler: (TransitionGraphModel) -> Void) {
        observers.append((object, handler))
    }
    
    public func removeObserver(object: AnyObject) {
        observers = observers.filter { $0.0 !== object}
    }
    
    private func notify() {
        for observer in observers {
            observer.1(self)
        }
    }
    //////////////////////////////////
    
    // MARK: Transition
    public var destination : String = "" {
        didSet {
            notify()
        }
    }   // Is it enough by normal KVO?

    public func needRemoveChildren(selfPath: ViewControllerPath, destinationPath: ViewControllerPath) -> Bool {
        return true
    }
}


