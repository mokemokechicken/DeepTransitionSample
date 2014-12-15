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
    public var destination : String = "" { didSet { notify() } }   // Is it enough by normal KVO?
//    private var pathList = [ViewControllerGraphPropertyProtocol]()

    public func needRemoveChildren(selfPath: String, destinationPath: String) -> Bool {
        return true
    }
    
    public func splitPath(path: String) -> [ViewControllerGraphPropertyProtocol] {
        var pathList = [ViewControllerGraphPropertyProtocol]()
        // /top
        // /top/news/show(id=10)
        // menu!/home
        // /top#coupon!show(id=10,shop=5)
        
        let tokens = tokenize(path)
        return pathList
    }

    private enum State {
        case Normal, ParamKey, ParamValue
    }
    
    // Private
    public func tokenize(path: String) -> [String] {
        var tokens = [String]()
        var token: String?
        let end = "\u{0}"
        var state: State = .Normal
        
        func flushToken(_ ch: String? = nil) {
            if let t = token { tokens.append(t); token = nil }
            if let c = ch { tokens.append(c) }
        }
        
        func addToken(ch: String) {
            token = (token ?? "") + ch
        }
        
        for chara in (path+end) {
            let ch = String(chara)
            switch state {
            case .Normal:
                switch ch {
                case SegueKind.Show.rawValue, SegueKind.Modal.rawValue, SegueKind.Tab.rawValue:
                    flushToken(ch)
                case end:
                    flushToken()
                    break
                case "(":
                    flushToken(ch)
                    state = .ParamKey
                default:
                    addToken(ch)
                }
            case .ParamKey:
                switch ch {
                case "=":
                    flushToken(ch)
                    state = .ParamValue
                default:
                    addToken(ch)
                }
                
            case .ParamValue:
                switch ch {
                case ",":
                    flushToken(ch)
                    state = .ParamKey
                case ")":
                    flushToken(ch)
                    state = .Normal
                default:
                    addToken(ch)
                }
            }
        }
        return tokens
    }
}


public enum SegueKind : String {
    case Show = "/"
    case Modal = "!"
    case Tab = "#"
}

public protocol ViewControllerGraphPropertyProtocol {
    var segueKind: SegueKind { get }
    var identifier : String { get }
    var params : [String:String] { get set }
}

public class ViewControllerGraphProperty : ViewControllerGraphPropertyProtocol {
    public let segueKind: SegueKind
    public let identifier : String
    public var params = [String:String]()
    
    public init(identifier: String, segueKind: SegueKind) {
        self.identifier  = identifier
        self.segueKind = segueKind
    }
    

}


