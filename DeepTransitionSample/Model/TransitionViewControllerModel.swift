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
    func reportFinishedRemoveViewControllerFrom(vc: HasTransitionContext?)
    func reportAddedViewController(vc: UIViewController?)
    func request(destination: String)

    func addContext(context: ViewControllerTransitionContext)
    func removeContext(context: ViewControllerTransitionContext)
}

@objc public class TransitionViewControllerModel : NSObject, TransitionCenterProtocol {
    public class func getInstance() -> TransitionViewControllerModel {
        return instance
    }
    
    private let _fsm : TransitionModelFSM!
    public override init() {
        super.init()
        _fsm = TransitionModelFSM(owner: self)
        _fsm.setDebugFlag(true)
    }
    
    // MARK: TransitionCenterProtocol
    public func reportFinishedRemoveViewControllerFrom(vc: HasTransitionContext?) {
        if let v = vc {
            async_fsm { $0.finish_remove(v) }
        } else {
            async_fsm { $0.stop() }
        }
    }
    
    public func reportAddedViewController(vc: UIViewController?) {
        if let v = vc {
            async_fsm { $0.finish_add(v)}
        } else {
            async_fsm { $0.stop() }
        }
    }

    public func request(destination: String) {
        async_fsm { $0.request(destination) }
    }
    //
    
    // MARK: Observable
    //////////////////////////////////
    private var contexts = [ViewControllerTransitionContext]()
    public func addContext(context: ViewControllerTransitionContext) {
        mylog("addContext: \(context.path)")
        contexts.append(context)
    }
    
    public func removeContext(context: ViewControllerTransitionContext) {
        let pre = contexts.count
        contexts = contexts.filter { $0.0 !== context}
        mylog("removeContext(\(pre) -> \(contexts.count)): \(context.path)")
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
    private var startPath : ViewControllerPath?
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
        switch (startPath, destPath) {
        case (let .Some(s), let .Some(d)):
            mylog("Finish Transition FROM \(s) TO \(currentPath)")
        default:
            break
        }
        destPath = nil
        startPath = nil
    }
    
    public func onRequestConfirming(destination: String!) {
        startPath = currentPath
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
        mylog("Start Transition FROM \(startPath!) TO \(destPath!)")
        async_fsm { $0.ok() }
    }
    
    func onEntryRemoving() {
        // TODO: Tab系のVCでContainer系のRootじゃない場合はその親にRequestを投げる必要がある
        let tInfo = calcTransitionInfo()
        if tInfo.oldComponentList.isEmpty {
            mylog("Skip Removing")
            async_fsm { $0.skip_removing() }
            return
        }
        
        if let context = findContextOf(tInfo.commonPath) { // 大丈夫なら大元に消すように言う
            mylog("Sending RemoveChildRequest to '\(context.path)'")
            context.removeChildViewController()
        } else {
            mylog("Can't send RemoveChildRequest to '\(tInfo.commonPath)'")
            async_fsm() { $0.stop() }
        }
    }
    
    func isExpectedReporter(object: AnyObject!) -> Bool {
        let tInfo = calcTransitionInfo()
        if let vc = object as? HasTransitionContext {
            if vc.transitionContext?.path == tInfo.commonPath {
                mylog("Change CurrentPath From \(currentPath.path) to \(tInfo.commonPath)")
                for context in self.caclWillRemoveContext(tInfo) {
                    removeContext(context)
                }
                currentPath = tInfo.commonPath
                return true
            }
        }
        return false
    }

    func onEntryAdding() {
        // TODO: Tab系のVCでContainer系のRootじゃない場合はその親にRequestを投げる必要がある
        let tInfo = calcTransitionInfo()
        var path = tInfo.commonPath
        if let willAdd = tInfo.newComponentList.first {
            if let context = findContextOf(path) {
                self.addingInfo = AddingInfo(tInfo: tInfo, adding: willAdd, vcContext: context)
                mylog("Sending AddChildRequest '\(context.path)' += \(willAdd.description)")
                context.addChildViewController(willAdd)
                return
            }
        }
        async_fsm { $0.stop() }
    }
    
    func isExpectedChild(object: AnyObject!) -> Bool {
        switch (addingInfo, object as? ViewControllerTransitionContextDelegate) {
        case(let .Some(ai), let .Some(vc)):
            if vc.transitionContext == nil || vc.transitionContext!.path == currentPath.appendPath(component: ai.adding) {
                return true
            }
        default:
            break
        }
        return false
    }
    
    func onFinishAdd(object: AnyObject!) {
        switch (addingInfo, object as? ViewControllerTransitionContextDelegate) {
        case(let .Some(ai), let .Some(vc)):
            if vc.transitionContext == nil {
                vc.transitionContext = ViewControllerTransitionContext(delegate: vc, center: self, baseContext: ai.vcContext, vcInfo: ai.adding)
            }
            if vc.transitionContext!.path == currentPath.appendPath(component: ai.adding) {
                mylog("Change CurrentPath From \(currentPath.path) to \(vc.transitionContext!.path)")
                currentPath = vc.transitionContext!.path
                addingInfo = nil
            }
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

