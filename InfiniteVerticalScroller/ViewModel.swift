//
//  ViewModel.swift
//  InfiniteVerticalScroller
//
//  Created by Luca Davanzo on 03/08/15.
//  Copyright (c) 2015 Luca Davanzo. All rights reserved.
//

import Foundation

class ViewModel: NSObject {
    
    private var array: [String] = []
    
    func loadObjects() {
        /* dummy array creation */
        for i in 1...30 {
            array.append(String(format: "foo - %i", i))
        }
    }
    
    func getObjects() -> [String] {
        return array
    }
    
}