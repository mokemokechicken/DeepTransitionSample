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
        checkSamePathComponent(target: pl.first, id: "top", kind: SegueKind.Show, params: nil)
    }

    func testSplitPath_2() {
        let pl = obj.splitPath("/top/news(id=10)")
        XCTAssertEqual(2, pl.count)
        checkSamePathComponent(target: pl.last, id: "news", kind: SegueKind.Show, params: ["id":"10"])
    }

    func testSplitPath_3() {
        let pl = obj.splitPath("/top#coupon!show(id=10,shop=5)")
        XCTAssertEqual(3, pl.count)
        if pl.count > 0 {
            checkSamePathComponent(target: pl[0], id: "top", kind: SegueKind.Show, params: nil)
        }
        if pl.count > 1 {
            checkSamePathComponent(target: pl[1], id: "coupon", kind: SegueKind.Tab, params: nil)
        }
        if pl.count > 2 {
            checkSamePathComponent(target: pl[2], id: "show", kind: SegueKind.Modal, params: ["id":"10", "shop":"5"])
        }
    }

    func testSplitPath_4() {
        let pl = obj.splitPath("/top!/menu/settings")
        XCTAssertEqual(3, pl.count)
        if pl.count > 1 {
            checkSamePathComponent(target: pl[1], id: "menu", kind: SegueKind.Modal, params: nil)
        }
    }

    func checkSamePathComponent(target t: ViewControllerGraphPropertyProtocol!, id: String, kind: SegueKind, params p: [String:String]? = nil) {
        if t == nil {
            XCTAssert(false, "Target Object is nil!")
            return
        }
        var params = p ?? [String:String]()
        XCTAssertEqual(id, t.identifier)
        XCTAssertEqual(kind, t.segueKind)
        XCTAssertEqual(params, t.params)
    }
    
    func testTokenize() {
        XCTAssertEqual(["/", "top", "/", "news"], obj.tokenize("/top/news"))
        XCTAssertEqual(["/", "top", "!", "/", "menu","/", "settings", "#", "prof"], obj.tokenize("/top!/menu/settings#prof"))
        XCTAssertEqual(["/", "top", "/", "news","/", "show", "(", "id", "=","10",",","url","=","http://hoge.com/mu?hoge=10#jj", ")"], obj.tokenize("/top/news/show(id=10,url=http://hoge.com/mu?hoge=10#jj)"))
    }
    

}
