//
//  TransitionModel.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

//import "DeepTransitionSample-Bridging-Header.h"

import Foundation
import UIKit

private let instance: TransitionViewControllerModel = TransitionViewControllerModel()


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

public protocol TransitionCenterProtocol {
    func reportFinishedRemoveViewController()
    func reportAddedViewController(vc: UIViewController?)
    func request(destination: String)

    func addContext(context: ViewControllerTransitionContext)
    func removeContext(context: ViewControllerTransitionContext)
}

@objc public class TransitionViewControllerModel : TransitionCenterProtocol {
    public class func getInstance() -> TransitionViewControllerModel {
        return instance
    }
    
    private let _fsm : TransitionModelFSM!
    public init() {
        _fsm = TransitionModelFSM(owner: self)
        _fsm.setDebugFlag(true)
    }
    
    // MARK: TransitionCenterProtocol
    public func reportFinishedRemoveViewController() {
        async_fsm { $0.add() }
    }
    
    public func reportAddedViewController(vc: UIViewController?) {
        async_fsm { $0.finish_add(vc)}
    }

    public func request(destination: String) {
        async_fsm { $0.request(destination) }
    }
    //
    
    // MARK: Observable
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
    private var destPath : ViewControllerPath?
    private var addingInfo : AddingInfo?

    struct AddingInfo {
        let tInfo : TransitionInfo
        let adding: ViewControllerGraphProperty
        let vcContext: ViewControllerTransitionContext
    }
    
    private func async_fsm(block:(TransitionModelFSM) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            block(self._fsm)
        }
    }
    
    private func mylog(s: String?) {
        #if DEBUG
        if let str = s {
            NSLog(str)
        }
        #endif
    }
    
    func onEntryIdle() {
        for context in self.caclWillRemoveContext(calcTransitionInfo()) {
            removeContext(context)
        }
        mylog("Finish Transition: \(currentPath.path) -> \(destPath?.path)")
        if let d = destPath {
            currentPath = destPath!
            destPath = nil
        }
    }
    
    public func onRequestConfirming(destination: String!) {
        if destination == nil {
            async_fsm { $0.cancel() }
            return
        }
        
        destPath = ViewControllerPath(path: destination!)
        if destPath == currentPath {
            async_fsm { $0.cancel() }
            return
        }
        
        let tInfo = calcTransitionInfo()
        for context in self.caclWillRemoveContext(tInfo) {
            if !context.canDisappearNow(destPath!) { // これから消されるVCに消えて大丈夫か尋ねる
                async_fsm { $0.cancel() }
                return
            }
        }
        async_fsm { $0.ok() }
    }
    
    func onEntryRemoving() {
        // TODO: Tab系のVCでContainer系のRootじゃない場合はその親にRequestを投げる必要がある
        let tInfo = calcTransitionInfo()
        if tInfo.oldComponentList.isEmpty {
            async_fsm { $0.add() }
            return
        }
        
        if let context = findContextOf(tInfo.commonPath) { // 大丈夫なら大元に消すように言う
            mylog("RemoveChildRequest to '\(context.path)'")
            context.removeChildViewController()
        } else {
            mylog("Can't send RemoveChildRequest to '\(tInfo.commonPath)'")
            async_fsm() { $0.stop() }
        }
    }
    
    
    func onEntryAdding() {
        // TODO: Tab系のVCでContainer系のRootじゃない場合はその親にRequestを投げる必要がある
        let tInfo = calcTransitionInfo()
        var path = tInfo.commonPath
        if let willAdd = tInfo.newComponentList.first {
            if let context = findContextOf(path) {
                self.addingInfo = AddingInfo(tInfo: tInfo, adding: willAdd, vcContext: context)
                mylog("AddChildRequest '\(context.path)' to \(willAdd.description)")
                context.addChildViewController(willAdd)
                return
            }
        }
        async_fsm { $0.stop() }
    }
    
    func onFinishAdd(object: AnyObject!) {
        switch (addingInfo, object as? ViewControllerTransitionContextDelegate) {
        case(let .Some(ai), let .Some(vc)):
            if vc.transitionContext == nil {
                vc.transitionContext = ViewControllerTransitionContext(delegate: vc, center: self, baseContext: ai.vcContext, vcInfo: ai.adding)
            }
            currentPath = vc.transitionContext!.path
        default:
            async_fsm() { $0.stop() }
            break
        }
    }
    
    func onEntryFinishAdd() {
        if currentPath == destPath {
            async_fsm { $0.finish_transition() }
        } else {
            async_fsm { $0.add() }
        }
    }

    // MARK: Utility
    private func calcTransitionInfo() -> TransitionInfo {
        if destPath == nil {
            return TransitionInfo(commonPath: currentPath, newComponentList: [ViewControllerGraphProperty](), oldComponentList: [ViewControllerGraphProperty]())
        }
        
        let (commonPath, d1, d2) = ViewControllerPath.diff(path1: currentPath, path2: destPath!)
        return TransitionInfo(commonPath: commonPath, newComponentList: d2, oldComponentList: d1)
    }
    
    private func caclWillRemoveContext(tInfo: TransitionInfo) -> [ViewControllerTransitionContext] {
        var ret = [ViewControllerTransitionContext]()
        var path = tInfo.commonPath
        for willRemoved in tInfo.oldComponentList {
            path = path.appendPath(component: willRemoved)
            if let context = findContextOf(path) {
                ret.append(context)
            }
        }
        return ret
    }
    
}

