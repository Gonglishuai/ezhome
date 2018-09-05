//
//  ESArray.swift
//  EZHome
//
//  Created by Admin on 2018/8/2.
//  Copyright © 2018年 EasyHome. All rights reserved.
//


extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(_ object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
