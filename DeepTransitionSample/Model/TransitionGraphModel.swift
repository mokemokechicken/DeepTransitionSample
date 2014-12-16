//
//  TransitionModel.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import Foundation
import UIKit

private let instance: TransitionViewControllerModel = TransitionViewControllerModel()


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

public class TransitionViewControllerModel {
    public class func getInstance() -> TransitionViewControllerModel {
        return instance
    }
    
    //////////////////////////////////
    private var contexts = [ViewControllerTransitionContext]()
    public func addContext(context: ViewControllerTransitionContext) {
        contexts.append(context)
    }
    
    public func removeContext(context: ViewControllerTransitionContext) {
        contexts = contexts.filter { $0.0 !== context}
    }
    
    private func findContextOf(path: ViewControllerPath) -> ViewControllerTransitionContext? {
        for c in contexts {
            if c.path? == path {
                return c
            }
        }
        return nil
    }
    //////////////////////////////////
    public private(set) var currentPath = ViewControllerPath(path: "")
    private var destPath = ViewControllerPath(path: "")

    enum State {
        case Init, Busy
    }
    var state: State = .Init
    
    public func request(destination: String) {
        switch state {
        case .Init:
            state = .Busy
            startTransition(destination)
        default:
            break
        }
    }
    
    private func cancelRequest() {
        state = .Init
    }
    
    private func finishRequest() {
        state = .Init
        currentPath = destPath
    }
    
    private func startTransition(destination: String) {
        destPath = ViewControllerPath(path: destination)
        let (commonPath, d1, d2) = ViewControllerPath.diff(path1: currentPath, path2: destPath)
        let tInfo = TransitionInfo(commonPath: commonPath, newComponentList: d2, oldComponentList: d1)
        removeChild(tInfo)
    }
    
    private func removeChild(tInfo: TransitionInfo) {
        var path = tInfo.commonPath
        for willRemoved in tInfo.oldComponentList {
            path = path.appendPath(willRemoved)
            if let context = findContextOf(path) {
                if !context.canDisappearNow(destPath) { // これから消されるVCに消えて大丈夫か尋ねる
                    cancelRequest()
                    return
                }
            }
        }
        //
        if let context = findContextOf(tInfo.commonPath) { // 大丈夫なら大元に消すように言う
            context.removeChildViewController {
                self.addChild(tInfo)
            }
        }
    }

    // 子供のViewController を順次追加していく
    private func addChild(tInfo: TransitionInfo) {
        var path = tInfo.commonPath
        if let willAdd = tInfo.newComponentList.first {
            if let context = findContextOf(path) {
                context.addChildViewController(willAdd) { vc in     // ひどい, かなしい
                    if let nextInfo = self.handlerAddViewController(tInfo, component: willAdd, context:context, viewController: vc) {
                        self.addChild(nextInfo)
                    } else {
                        self.finishRequest()
                    }
                }
            } else {
                finishRequest()
            }
        } else {
            finishRequest()
        }
    }
    
    private func handlerAddViewController(tInfo: TransitionInfo, component: ViewControllerGraphProperty, context: ViewControllerTransitionContext, viewController: UIViewController?) -> TransitionInfo? {
        if let vc = viewController as? ViewControllerTransitionContextDelegate {
            if vc.transitionContext == nil {
                vc.transitionContext = ViewControllerTransitionContext()
                vc.transitionContext!.setup(context, vcInfo: component)
            }
            
            let nextPath = tInfo.commonPath.appendPath(component)
            var nextNewList = [ViewControllerGraphProperty]()
            for c in tInfo.newComponentList[1..<tInfo.newComponentList.count] {
                nextNewList.append(c)
            }
            return TransitionInfo(commonPath: nextPath, newComponentList: nextNewList, oldComponentList: tInfo.oldComponentList)
            
        }
        return nil
    }
}

