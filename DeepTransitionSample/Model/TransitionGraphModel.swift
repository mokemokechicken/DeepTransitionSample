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
        
        var segue: SegueKind = SegueKind.Modal
        var name: String? = nil
        var paramKey: String?
        var params = [String:String]()
        
        func addPath() {
            if let id = name {
                pathList.append(ViewControllerGraphProperty(identifier: id, segueKind: segue, params:params))
            }
            name = nil
            params = [String:String]()
        }
        
        for token in tokens {
            switch token {
            case .KindShow:
                addPath()
                segue = .Show
            case .KindModal:
                addPath()
                segue = .Modal
            case .KindTab:
                addPath()
                segue = .Tab

            case .VC(let n): name = n
            case .ParamKey(let k): paramKey = k
            case .ParamValue(let v): if let k = paramKey { params[k] = v }
            case .End:
                addPath()
                break
            }


        }
        return pathList
    }
    

    private enum State {
        case Normal, ParamKey, ParamValue
    }
    
    public enum Token : Equatable {
        case VC(String)
        case ParamKey(String)
        case ParamValue(String)
        case KindShow, KindModal, KindTab
        case End
        
    }
    
    // Private なんだけど UnitTest用にPublic
    public func tokenize(path: String) -> [Token] {
        var tokens = [Token]()
        var tstr: String?
        let end = "\u{0}"
        var state: State = .Normal
        
        
        func addToken(ch: String) {
            tstr = (tstr ?? "") + ch
        }
        
        for chara in (path+end) {
            let ch = String(chara)
            switch state {
            case .Normal:
                switch ch {
                case SegueKind.Show.rawValue:
                    if let t = tstr { tokens.append(Token.VC(t)); tstr = nil }
                    tokens.append(Token.KindShow)
                    
                case SegueKind.Modal.rawValue:
                    if let t = tstr { tokens.append(Token.VC(t)); tstr = nil }
                    tokens.append(Token.KindModal)
                    
                case SegueKind.Tab.rawValue:
                    if let t = tstr { tokens.append(Token.VC(t)); tstr = nil }
                    tokens.append(Token.KindTab)

                case end:
                    if let t = tstr { tokens.append(Token.VC(t)); tstr = nil }
                    tokens.append(.End)
                    break
                case "(":
                    if let t = tstr { tokens.append(Token.VC(t)); tstr = nil }
                    state = .ParamKey
                default:
                    addToken(ch)
                }
            case .ParamKey:
                switch ch {
                case "=":
                    if let t = tstr { tokens.append(Token.ParamKey(t)); tstr = nil }
                    state = .ParamValue
                default:
                    addToken(ch)
                }
                
            case .ParamValue:
                switch ch {
                case ",":
                    if let t = tstr { tokens.append(Token.ParamValue(t)); tstr = nil }
                    state = .ParamKey
                case ")":
                    if let t = tstr { tokens.append(Token.ParamValue(t)); tstr = nil }
                    state = .Normal
                default:
                    addToken(ch)
                }
            }
        }
        return tokens
    }
}

public func ==(lhs: TransitionGraphModel.Token, rhs: TransitionGraphModel.Token) -> Bool {
    switch (lhs, rhs) {
    case (.VC(let a), .VC(let b)) where a == b: return true
    case (.ParamKey(let a), .ParamKey(let b)) where a == b: return true
    case (.ParamValue(let a), .ParamValue(let b)) where a == b: return true
    case (.KindShow, .KindShow): return true
    case (.KindModal, .KindModal): return true
    case (.KindTab, .KindTab): return true
    case (.End, .End): return true
    default:
        return false
    }
}



public enum SegueKind : String {
    case Show = "/"
    case Modal = "!"
    case Tab = "#"
}

public protocol ViewControllerGraphPropertyProtocol {
    var segueKind: SegueKind { get }
    var identifier: String { get }
    var params: [String:String] { get }
}

public class ViewControllerGraphProperty : ViewControllerGraphPropertyProtocol {
    public let segueKind: SegueKind
    public let identifier: String
    public let params: [String:String]
    
    public init(identifier: String, segueKind: SegueKind, params:[String:String]) {
        self.identifier  = identifier
        self.segueKind = segueKind
        self.params = params
    }
}


