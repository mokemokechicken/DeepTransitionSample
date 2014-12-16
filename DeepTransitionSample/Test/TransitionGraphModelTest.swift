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

typealias SegueKind = ViewControllerPath.SegueKind
typealias ContainerKind = ViewControllerPath.ContainerKind

class TransitionGraphModelTest: XCTestCase {
    let obj = ViewControllerPath(path: "")

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

    func checkSamePathComponent(target t: ViewControllerGraphProperty!, id: String, kind: SegueKind, root: ContainerKind = ContainerKind.None, params p: [String:String]? = nil) {
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
    
    typealias T = ViewControllerPath.Token
    func testTokenize() {
        
        XCTAssertEqual([T.KindShow, T.VC("top"), T.KindShow, T.VC("news"), T.End], obj.tokenize("/top/news"))
        XCTAssertEqual([T.KindShow, T.VC("top"), T.KindModal, T.KindShow, T.VC("menu"),T.KindShow, T.VC("settings"), T.KindTab, T.VC("prof"), T.End], obj.tokenize("/top!/menu/settings#prof"))
        XCTAssertEqual([T.KindShow, T.VC("top"), T.KindShow, T.VC("news"),T.KindShow, T.VC("show"),
            T.ParamKey("id"), T.ParamValue("10"),
            T.ParamKey("url"),T.ParamValue("http://hoge.com/mu?hoge=10#jj"), T.End],
            obj.tokenize("/top/news/show(id=10,url=http://hoge.com/mu?hoge=10#jj)"))
    }
    

    func testIsDifferenceRoot() {
        let path = ViewControllerPath(path: "/a/b/c")
        XCTAssertEqual(true, path.isDifferenceRoot(ViewControllerPath(path: "/a/b/d")))
        XCTAssertEqual(false, path.isDifferenceRoot(ViewControllerPath(path: "/a/b/c/d")))
        XCTAssertEqual(false, path.isDifferenceRoot(ViewControllerPath(path: "/a/c/d")))
        XCTAssertEqual(false, path.isDifferenceRoot(ViewControllerPath(path: "/b")))
        XCTAssertEqual(true, path.isDifferenceRoot(ViewControllerPath(path: "/a/b!c")))
        
        let p2 = ViewControllerPath(path: "menu")
        XCTAssertEqual(true , p2.isDifferenceRoot(ViewControllerPath(path: "/a/b!c")))
        XCTAssertEqual(false, p2.isDifferenceRoot(ViewControllerPath(path: "menu!/top")))
        XCTAssertEqual(true , p2.isDifferenceRoot(ViewControllerPath(path: "/menu!/top")))
    }
    
    func testDiff_1() {
        let path1 = ViewControllerPath(path: "/a/b/c")
        let path2 = ViewControllerPath(path: "/a/b/e/f")
        let (common, d1, d2) = ViewControllerPath.diff(path1: path1, path2: path2)
        XCTAssertEqual(2, common.depth)
        XCTAssertEqual(1, d1.count)
        XCTAssertEqual(2, d2.count)
        XCTAssertEqual("a", common.componentList[0].identifier)
        XCTAssertEqual("b", common.componentList[1].identifier)
        XCTAssertEqual("c", d1[0].identifier)
        XCTAssertEqual("e", d2[0].identifier)
        XCTAssertEqual("f", d2[1].identifier)
    }

    func testDiff_2() {
        let path1 = ViewControllerPath(path: "/a(id=1)/b(id=3)/c")
        let path2 = ViewControllerPath(path: "/a(id=1)/b(id=4)/e/f")
        let (common, d1, d2) = ViewControllerPath.diff(path1: path1, path2: path2)
        XCTAssertEqual(1, common.depth)
        XCTAssertEqual(2, d1.count)
        XCTAssertEqual(3, d2.count)
        XCTAssertEqual("a", common.componentList[0].identifier)
        XCTAssertEqual("b", d1[0].identifier)
        XCTAssertEqual("id=3", d1[0].paramString())
        XCTAssertEqual("c", d1[1].identifier)
        XCTAssertEqual("b", d2[0].identifier)
        XCTAssertEqual("id=4", d2[0].paramString())
        XCTAssertEqual("e", d2[1].identifier)
        XCTAssertEqual("f", d2[2].identifier)
    }
    
    func testDiff_3() {
        let path1 = ViewControllerPath(path: "")
        let path2 = ViewControllerPath(path: "/a/b")
        let (common, d1, d2) = ViewControllerPath.diff(path1: path1, path2: path2)
        XCTAssertEqual(0, common.depth)
        XCTAssertEqual(0, d1.count)
        XCTAssertEqual(2, d2.count)
        XCTAssertEqual("a", d2[0].identifier)
        XCTAssertEqual("b", d2[1].identifier)
    }

    func testComponentListToPath_1() {
        var path = ""
        path = "/a/b/c"; XCTAssertEqual(path, ViewControllerPath.componentListToPath(ViewControllerPath(path: path).componentList))
        path = ""; XCTAssertEqual(path, ViewControllerPath.componentListToPath(ViewControllerPath(path: path).componentList))
        path = "a"; XCTAssertEqual(path, ViewControllerPath.componentListToPath(ViewControllerPath(path: path).componentList))
        path = "a!b!/c"; XCTAssertEqual(path, ViewControllerPath.componentListToPath(ViewControllerPath(path: path).componentList))
        path = "a#b!/c"; XCTAssertEqual(path, ViewControllerPath.componentListToPath(ViewControllerPath(path: path).componentList))
        path = "a#/b!/c(id=10,url=http://hoge.com/hoge?ud=10#jjj)/ddx"; XCTAssertEqual(path, ViewControllerPath.componentListToPath(ViewControllerPath(path: path).componentList))
    }
}
