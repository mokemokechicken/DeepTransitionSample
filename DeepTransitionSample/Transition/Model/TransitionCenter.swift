//
//  TransitionModel.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

//import "DeepTransitionSample-Bridging-Header.h"

import Foundation


public protocol TransitionCenterProtocol {
    func addAgent(agent: TransitionAgentProtocol)
    func reportFinishedRemoveViewControllerFrom(path: TransitionPath)
    func reportViewDidAppear(path: TransitionPath)
    func reportTransitionError(reason: String?)
    func to(destination: String)
}

@objc public class TransitionCenter : NSObject, TransitionCenterProtocol {

    private let _fsm : TransitionModelFSM!
    public override init() {
        super.init()
        _fsm = TransitionModelFSM(owner: self)
        _fsm.setDebugFlag(true)
    }
    
    // MARK: TransitionCenterProtocol
    public func reportFinishedRemoveViewControllerFrom(path: TransitionPath) {
        async_fsm { $0.finish_remove(path) }
    }
    
    public func reportViewDidAppear(path: TransitionPath) {
        async_fsm { $0.move(path) }
    }
    
    public func reportTransitionError(reason: String?) {
        let r = reason ?? ""
        mylog("TransitionError: \(r)")
        async_fsm { $0.stop() }
    }

    public func to(destination: String) {
        async_fsm { $0.request(destination) }
    }
    //
    
    // MARK: Observable
    //////////////////////////////////
    private var agents = [WeakAgent]()
    public func addAgent(agent: TransitionAgentProtocol) {
        mylog("addAgent: \(agent.transitionPath)")
        agents.append(WeakAgent(agent: agent))
    }
    
    private func findAgentOf(path: TransitionPath) -> TransitionAgentProtocol? {
        for c in agents {
            if path ==  c.agent?.transitionPath {
                return c.agent
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
        let nextComponent: TransitionPathComponent
        let agent: TransitionAgentProtocol
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
        
        if let agent = findAgentOf(tInfo.commonPath) { // 大丈夫なら大元に消すように言う
            mylog("Sending RemoveChildRequest to '\(agent.transitionPath)'")
            agent.removeViewController(tInfo.oldComponentList.first!)
        } else {
            mylog("Can't send RemoveChildRequest to '\(tInfo.commonPath)'")
            async_fsm() { $0.stop() }
        }
    }
    
    func isExpectedReporter(object: AnyObject!) -> Bool {
        let tInfo = calcTransitionInfo()
        if let path = object as? TransitionPath {
            if path == tInfo.commonPath {
                mylog("Change CurrentPath From \(currentPath.path) to \(path)")
                currentPath = path
                return true
            }
        }
        return false
    }

    func onEntryAdding() {
        // TODO: Tab系のVCでContainer系のRootじゃない場合はその親にRequestを投げる必要がある
        let tInfo = calcTransitionInfo()
        var path : TransitionPath? = tInfo.commonPath
        if let nextComponent = tInfo.newComponentList.first {
            while path != nil {
                if let agent = findAgentOf(path!) {
                    self.addingInfo = AddingInfo(tInfo: tInfo, nextComponent: nextComponent, agent: agent)
                    mylog("Sending AddChildRequest '\(agent.transitionPath)' += \(nextComponent.description)")
                    if agent.addViewController(nextComponent) {
                        return
                    }
                }
                path = path!.up()
            }
        }
        async_fsm { $0.stop() }
    }
    
    func isExpectedChild(object: AnyObject!) -> Bool {
        switch (addingInfo, object as? TransitionPath) {
        case(let .Some(ai), let .Some(path)):
            if path == currentPath.appendPath(component: ai.nextComponent) {
                return true
            }
        default:
            break
        }
        return false
    }
    
    func onMove(object: AnyObject!) {
        if let path = object as? TransitionPath {
            mylog("Change CurrentPath From \(currentPath.path) to \(path)")
            currentPath = path
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
    
    private func caclWillRemoveContext(tInfo: TransitionInfo) -> [TransitionAgentProtocol] {
        var ret = [TransitionAgentProtocol]()
        var path = tInfo.commonPath
        for willRemoved in tInfo.oldComponentList {
            path = path.appendPath(component: willRemoved)
            if let agent = findAgentOf(path) {
                ret.append(agent)
            }
        }
        return ret
    }
}

private class WeakAgent {
    private weak var agent:TransitionAgentProtocol?
    init(agent: TransitionAgentProtocol) {
        self.agent = agent
    }
}

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




