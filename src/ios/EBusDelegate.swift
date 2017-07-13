//
//  EBusDelegate.swift
//  TestSocketIO
//
//  Created by Pan Alex on 2017/5/11.
//  Copyright © 2017年 Pan Alex. All rights reserved.
//
import Foundation

protocol EBusDelegate : NSObjectProtocol {
    
    func msgCallback(data:JSON)
    func msgUnReadCallback(data:JSON)
    func msgUnReadInitCallback(data:JSON)
    func socketStatusChange()

}
