//
//  TransitionModel.swift
//  DeepTransitionSample
//
//  Created by 森下 健 on 2014/12/13.
//  Copyright (c) 2014年 Yumemi. All rights reserved.
//

import Foundation

private let instance: TransitionModel = TransitionModel()

public class TransitionModel {
    public class func getInstance() -> TransitionModel {
        return instance
    }
    
    public var location: String = "/"
}
