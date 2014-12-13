//
//  TreeTransitionViewController.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import UIKit

class TreeTransitionViewController: UIViewController {
    let transitionModel = TransitionModel.getInstance()
    var path:String = ""
    var childs = [String]()
    
    func transition(_ to: String? = nil) -> Bool {
        if let location = to {
            transitionModel.location = location
        }
        let loc = transitionModel.location
        if !loc.hasPrefix(path) {
            self.navigationController?.popViewControllerAnimated(true)
            return true
        }
        for ch in childs {
            if loc.hasPrefix("\(path)/\(ch)") {
                performSegueWithIdentifier(ch, sender: self)
                return true
            }
        }
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
        if transition() { return }
        super.viewWillAppear(animated)
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if self.parentViewController !== parent {
            let loc = transitionModel.location
            if loc.hasPrefix(path) {
                var strings = split(path, { $0 == "/"})
                strings.removeLast()
                transitionModel.location = "/" + join("/", strings)
            }
        }
    }

}
