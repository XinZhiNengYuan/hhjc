//
//  MyRegex.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/23.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//


import Foundation

struct MyRegex {
    let regex: NSRegularExpression?
    
    init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern,
                                         options: .caseInsensitive)
    }
    
    func match(input: String) -> Bool {
        if let matches = regex?.matches(in: input,
                                                options: [],
                                                range: NSMakeRange(0, (input as NSString).length)) {
            return matches.count > 0
        } else {
            return false
        }
    }
}
