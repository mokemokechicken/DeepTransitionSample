//
//  TransitionGraphModelTest.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/15.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit
import XCTest

import DeepTransitionSample


class TransitionGraphModelTest: XCTestCase {
    let obj = TransitionGraphModel.getInstance()

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSplitPath_1() {
        let pl = obj.splitPath("/top")
        XCTAssertEqual(1, pl.count)
        checkSamePathComponent(target: pl.first, id: "top", kind: SegueKind.Show, root: .Navigation, params: nil)
    }

    func testSplitPath_2() {
        let pl = obj.splitPath("/top/news(id=10)")
        XCTAssertEqual(2, pl.count)
        checkSamePathComponent(target: pl.first, id: "top", kind: SegueKind.Show, root: .Navigation, params: nil)
        checkSamePathComponent(target: pl.last, id: "news", kind: SegueKind.Show, params: ["id":"10"])
    }

    func testSplitPath_3() {
        let pl = obj.splitPath("/top#coupon!show(id=10,shop=5)")
        XCTAssertEqual(3, pl.count)
        if pl.count > 0 {
            checkSamePathComponent(target: pl[0], id: "top", kind: SegueKind.Show, root: .Navigation, params: nil)
        }
        if pl.count > 1 {
            checkSamePathComponent(target: pl[1], id: "coupon", kind: SegueKind.Tab, params: nil)
        }
        if pl.count > 2 {
            checkSamePathComponent(target: pl[2], id: "show", kind: SegueKind.Modal, params: ["id":"10", "shop":"5"])
        }
    }

    func testSplitPath_4() {
        let pl = obj.splitPath("/top!/menu#/settings")
        XCTAssertEqual(3, pl.count)
        if pl.count > 0 {
            checkSamePathComponent(target: pl[0], id: "top", kind: SegueKind.Show, root: .Navigation, params: nil)
        }
        if pl.count > 1 {
            checkSamePathComponent(target: pl[1], id: "menu", kind: SegueKind.Modal, root: .Navigation, params: nil)
        }
        if pl.count > 2 {
            checkSamePathComponent(target: pl[2], id: "settings", kind: SegueKind.Tab, root: .Navigation, params: nil)
        }
    }

    func testSplitPath_5() {
        let pl = obj.splitPath("menu!/home/follows")
        XCTAssertEqual(3, pl.count)
        if pl.count > 0 {
            checkSamePathComponent(target: pl[0], id: "menu", kind: SegueKind.Show, root: .None, params: nil)
        }
        if pl.count > 1 {
            checkSamePathComponent(target: pl[1], id: "home", kind: SegueKind.Modal, root: .Navigation, params: nil)
        }
        if pl.count > 2 {
            checkSamePathComponent(target: pl[2], id: "follows", kind: SegueKind.Show, root: .None, params: nil)
        }
    }

    func testSplitPath_6() {
        let pl = obj.splitPath("menu#/home/follows")
        XCTAssertEqual(3, pl.count)
        if pl.count > 0 {
            checkSamePathComponent(target: pl[0], id: "menu", kind: SegueKind.Show, root: .None, params: nil)
        }
        if pl.count > 1 {
            checkSamePathComponent(target: pl[1], id: "home", kind: SegueKind.Tab, root: .Navigation, params: nil)
        }
        if pl.count > 2 {
            checkSamePathComponent(target: pl[2], id: "follows", kind: SegueKind.Show, root: .None, params: nil)
        }
    }

    func checkSamePathComponent(target t: ViewControllerGraphPropertyProtocol!, id: String, kind: SegueKind, root: ContainerKind = ContainerKind.None, params p: [String:String]? = nil) {
        if t == nil {
            XCTAssert(false, "Target Object is nil!")
            return
        }
        var params = p ?? [String:String]()
        XCTAssertEqual(id, t.identifier)
        XCTAssertEqual(kind, t.segueKind)
        XCTAssertEqual(params, t.params)
        XCTAssertEqual(root, t.ownRootContainer)
    }
    
    typealias T = TransitionGraphModel.Token
    func testTokenize() {
        
        XCTAssertEqual([T.KindShow, T.VC("top"), T.KindShow, T.VC("news"), T.End], obj.tokenize("/top/news"))
        XCTAssertEqual([T.KindShow, T.VC("top"), T.KindModal, T.KindShow, T.VC("menu"),T.KindShow, T.VC("settings"), T.KindTab, T.VC("prof"), T.End], obj.tokenize("/top!/menu/settings#prof"))
        XCTAssertEqual([T.KindShow, T.VC("top"), T.KindShow, T.VC("news"),T.KindShow, T.VC("show"),
            T.ParamKey("id"), T.ParamValue("10"),
            T.ParamKey("url"),T.ParamValue("http://hoge.com/mu?hoge=10#jj"), T.End],
            obj.tokenize("/top/news/show(id=10,url=http://hoge.com/mu?hoge=10#jj)"))
    }
    

}
