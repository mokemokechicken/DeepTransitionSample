//
//  TransitionModel.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import Foundation
import UIKit

private let instance: TransitionModel = TransitionModel()

public class TransitionModel {
    public class func getInstance() -> TransitionModel {
        return instance
    }
    
    public var destination: String = "/"
    
    // MARK: Observable
    ///////// Observable ///////////
    public typealias NotificationHandler = (TransitionModel) -> Void
    
    private var observers = [(AnyObject, NotificationHandler)]()
    public func addObserver(object: AnyObject, handler: (TransitionModel) -> Void) {
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
    
    
    
}



