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

private let instance: TransitionCenter = TransitionCenter()


private class TransitionInfo {
    private let commonPath : TransitionPath
    private let newComponentList : [TransitionPathComponent]
    private let oldComponentList : [TransitionPathComponent]
    
    private init(commonPath: TransitionPath, newComponentList: [TransitionPathComponent], oldComponentList: [TransitionPathComponent])  {
        self.commonPath = commonPath
        self.newComponentList = newComponentList
        self.oldComponentList = oldComponentList
    }
}

public protocol TransitionCenterProtocol {
    func addContext(context: TransitionAgent)
    func reportFinishedRemoveViewControllerFrom(vc: HasTransitionAgent?)
    func reportViewDidAppear(vc: HasTransitionAgent)
    func reportTransitionError(reason: String?)
    func request(destination: String)
}


class WeakAgent {
    private weak var context:TransitionAgent?
    init(context: TransitionAgent) {
        self.context = context
    }
}


@objc public class TransitionCenter : NSObject, TransitionCenterProtocol {
    public class func getInstance() -> TransitionCenter {
        return instance
    }
    
    private let _fsm : TransitionModelFSM!
    public override init() {
        super.init()
        _fsm = TransitionModelFSM(owner: self)
        _fsm.setDebugFlag(true)
    }
    
    // MARK: TransitionCenterProtocol
    public func reportFinishedRemoveViewControllerFrom(vc: HasTransitionAgent?) {
        if let v = vc {
            async_fsm { $0.finish_remove(v) }
        } else {
            async_fsm { $0.stop() }
        }
    }
    
    public func reportViewDidAppear(vc: HasTransitionAgent) {
        async_fsm { $0.move(vc) }
    }
    
    public func reportTransitionError(reason: String?) {
        let r = reason ?? ""
        mylog("TransitionError: \(r)")
        async_fsm { $0.stop() }
    }

    public func request(destination: String) {
        async_fsm { $0.request(destination) }
    }
    //
    
    // MARK: Observable
    //////////////////////////////////
    private var contexts = [WeakAgent]()
    public func addContext(context: TransitionAgent) {
        mylog("addContext: \(context.path)")
        contexts.append(WeakAgent(context: context))
    }
    
    private func findContextOf(path: TransitionPath) -> TransitionAgent? {
        for c in contexts {
            if path ==  c.context?.path {
                return c.context
            }
        }
        return nil
    }
    //////////////////////////////////

    public private(set) var currentPath = TransitionPath(path: "")
    private var startPath : TransitionPath?
    private var destPath : TransitionPath?
    private var addingInfo : AddingInfo?

    private struct AddingInfo {
        let tInfo : TransitionInfo
        let adding: TransitionPathComponent
        let vcContext: TransitionAgent
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
        
        destPath = TransitionPath(path: destination!)
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
        if let vc = object as? HasTransitionAgent {
            if vc.transitionContext?.path == tInfo.commonPath {
                mylog("Change CurrentPath From \(currentPath.path) to \(tInfo.commonPath)")
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
        switch (addingInfo, object as? HasTransitionAgent) {
        case(let .Some(ai), let .Some(vc)):
            if vc.transitionContext == nil || vc.transitionContext!.path == currentPath.appendPath(component: ai.adding) {
                return true
            }
        default:
            break
        }
        return false
    }
    
    func onMove(object: AnyObject!) {
        if let hasContext = object as? HasTransitionAgent {
            if let context = hasContext.transitionContext {
                mylog("Change CurrentPath From \(currentPath.path) to \(context.path)")
                currentPath = context.path
            }
        }
    }
    
    func onEntryMoved() {
        addingInfo = nil
        if currentPath == destPath {
            async_fsm { $0.finish_transition() }
        } else {
            async_fsm { $0.add() }
        }
    }

    // MARK: Utility
    private func calcTransitionInfo() -> TransitionInfo {
        if destPath == nil {
            return TransitionInfo(commonPath: currentPath, newComponentList: [TransitionPathComponent](), oldComponentList: [TransitionPathComponent]())
        }
        
        let (commonPath, d1, d2) = TransitionPath.diff(path1: currentPath, path2: destPath!)
        return TransitionInfo(commonPath: commonPath, newComponentList: d2, oldComponentList: d1)
    }
    
    private func caclWillRemoveContext(tInfo: TransitionInfo) -> [TransitionAgent] {
        var ret = [TransitionAgent]()
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

