//
//  ViewControllerPath.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/15.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import Foundation


@objc public class ViewControllerPath : Hashable, Printable {
    public let path: String
    public private(set) var componentList = [ViewControllerGraphProperty]()
    public var depth : Int { return componentList.count }

    public init(path: String) {
        self.path = path
        self.componentList = splitPath(path)
    }
    
    private init(componentList: [ViewControllerGraphProperty]) {
        self.path = ViewControllerPath.componentListToPath(componentList)
        self.componentList = componentList
    }
    
    public func appendPath(component: ViewControllerGraphProperty) -> ViewControllerPath {
        return ViewControllerPath(componentList: self.componentList + [component])
    }

    public func appendPath(componentList: [ViewControllerGraphProperty]) -> ViewControllerPath {
        return ViewControllerPath(componentList: self.componentList + componentList)
    }

    public func appendPath(path: ViewControllerPath) -> ViewControllerPath {
        return ViewControllerPath(componentList: self.componentList + path.componentList)
    }
    
    public class func diff(#path1: ViewControllerPath, path2: ViewControllerPath) -> (common: ViewControllerPath, d1: [ViewControllerGraphProperty], d2: [ViewControllerGraphProperty]) {
        let minDepth = min(path1.depth, path2.depth)
        var common = [ViewControllerGraphProperty]()
        var d1 = [ViewControllerGraphProperty]()
        var d2 = [ViewControllerGraphProperty]()

        var diffRootIndex = -1
        for i in 0..<minDepth {
            if path1.componentList[i] == path2.componentList[i] {
                common.append(path1.componentList[i])
            } else {
                diffRootIndex = i
                break
            }
        }
        if diffRootIndex > -1 {
            for i1 in diffRootIndex..<path1.depth {
                d1.append(path1.componentList[i1])
            }
            for i2 in diffRootIndex..<path2.depth {
                d2.append(path2.componentList[i2])
            }
        }
        return (ViewControllerPath(componentList: common), d1, d2)
    }
    
    public func isDifferenceRoot(destinationPath: ViewControllerPath) -> Bool {
        // path の 最後の要素以外が一致していて、かつ、最後の要素が一致してなければTrue。
        // それ以外はFalse
        if destinationPath.depth < depth || depth == 0 {
            return false
        }
        
        for i in 0..<(depth-1) {
            if destinationPath.componentList[i] != componentList[i] {
                return false
            }
        }
        let lastIndex = depth-1
        if destinationPath.componentList[lastIndex] != componentList[lastIndex] {
            return true
        }
        return false
    }
    
    public class func componentListToPath(componentList: [ViewControllerGraphProperty]) -> String {
        if componentList.isEmpty {
            return ""
        }
        var str = ""
        for c in componentList  {
            str += c.description
        }
        return str.substringFromIndex(advance(str.startIndex, 1))
    }
    
    // MARK: Enums
    public enum SegueKind : String {
        case Show = "/"
        case Modal = "!"
        case Tab = "#"
    }
    
    public enum ContainerKind : String, Printable {
        case None = "None"
        case Navigation = "Navigation"
        
        public var description : String {
            return "ContainerKind.\(self.rawValue)"
        }
    }
    
    // MARK: Hashable
    public var hashValue : Int { return path.hashValue }

    // MARK: Printable
    public var description: String { return path }
    
    // MARK: Private
    // Private なんだけど UnitTest用にPublic
    public func splitPath(path: String) -> [ViewControllerGraphProperty] {
        var pathList = [ViewControllerGraphProperty]()
        let tokens = tokenize(path)
        var alreadyHasNavigationController = false
        var ownContainer = ContainerKind.None
        var segue: SegueKind?
        var name: String? = nil
        var paramKey: String?
        var params = [String:String]()
        
        func addPath() {
            if let id = name {
                if let seg = segue {
                    pathList.append(ViewControllerGraphProperty(identifier: id, segueKind: seg, params:params, ownRootContainer: ownContainer))
                    if !alreadyHasNavigationController && ownContainer == .Navigation {
                        alreadyHasNavigationController = true
                    }
                    name = nil
                    params = [String:String]()
                    segue = nil
                    ownContainer = .None
                }
            }
        }
        
        for token in tokens {
            switch token {
            case .KindShow:
                addPath()
                switch (alreadyHasNavigationController, segue) {
                case (_, .Some(.Modal)): // "!/"
                    ownContainer = .Navigation
                case (_, .Some(.Tab)):   // "#/"
                    ownContainer = .Navigation
                case (false, .None):
                    ownContainer = .Navigation
                    segue = .Show
                default:
                    segue = .Show
                }
            case .KindModal:
                addPath()
                segue = .Modal
                alreadyHasNavigationController = false
            case .KindTab:
                addPath()
                segue = .Tab
                
            case .VC(let n):
                name = n
                segue = segue ?? .Show
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
    
    public enum Token : Equatable, Printable {
        case VC(String)
        case ParamKey(String)
        case ParamValue(String)
        case KindShow, KindModal, KindTab
        case End
        
        public var description: String {
            switch self {
            case .VC(let s):
                return "VC(\(s))"
            case .ParamKey(let s):
                return "Key(\(s))"
            case .ParamValue(let s):
                return "Val(\(s))"
            case .KindShow:
                return "/"
            case .KindModal:
                return "!"
            case .KindTab:
                return "#"
            case .End:
                return "$"
            }
        }
    }
    
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

public func ==(lhs: ViewControllerPath, rhs: ViewControllerPath) -> Bool {
    if lhs.depth == rhs.depth {
        for i in 0..<lhs.depth {
            if lhs.componentList[i] != rhs.componentList[i] {
                return false
            }
        }
        return true
    }
    return false
}


public func ==(lhs: ViewControllerPath.Token, rhs: ViewControllerPath.Token) -> Bool {
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


public func ==(lhs: ViewControllerGraphProperty, rhs: ViewControllerGraphProperty) -> Bool {
    return lhs.isEqual(rhs)
}

@objc public class ViewControllerGraphProperty : Printable, Equatable {
    public let segueKind: ViewControllerPath.SegueKind
    public let identifier: String
    public let params: [String:String]
    public let ownRootContainer: ViewControllerPath.ContainerKind
    
    public init(identifier: String, segueKind: ViewControllerPath.SegueKind, params:[String:String], ownRootContainer: ViewControllerPath.ContainerKind) {
        self.identifier  = identifier
        self.segueKind = segueKind
        self.params = params
        self.ownRootContainer = ownRootContainer
    }
    
    public func isEqual(other: ViewControllerGraphProperty) -> Bool {
        return
            self.identifier == other.identifier &&
                self.segueKind == other.segueKind &&
                self.ownRootContainer == other.ownRootContainer &&
                self.paramString() == other.paramString()
    }
    
    public var description: String {
        var pstr = paramString()
        if !pstr.isEmpty {
            pstr = "(\(pstr))"
        }
        var ret = ""
        switch ownRootContainer {
        case .None:
            ret = "\(segueKind.rawValue)\(identifier)\(pstr)"
        case .Navigation:
            ret = "\(segueKind.rawValue)/\(identifier)\(pstr)"
        }
        return ret
    }
    
    public func paramString() -> String {
        var kvList = [String]()
        for k in params.keys.array.sorted(<) {
            kvList.append("\(k)=\(params[k]!)")
        }
        return join(",", kvList)
    }
}

