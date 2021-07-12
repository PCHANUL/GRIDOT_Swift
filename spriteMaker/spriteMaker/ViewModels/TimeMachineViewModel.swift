//
//  TimeMachineViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/07/12.
//

import UIKit

class TimeMachineViewModel: NSObject {
    private var timeGrid: [String]!
    var maxTime: Int!
    var oldPoint: Int!
    
    override init() {
        timeGrid = []
        maxTime = 10
    }
    
    func addTime(_ gridData: String) {
        if (timeGrid.count > maxTime) {
            oldPoint += 1
        }
        timeGrid.append(gridData)
        if (oldPoint == maxTime) {
            relocateTimes()
        }
    }
    
    func relocateTimes() {
        var newTime: [String] = []
        for x in 0..<maxTime {
            
        }
    }
    
}



// maxTime이 timeGrid.count 보다 작은 경우에 앞에서 하나씩 지운다.
// 만약에 앞에서 지운 갯수가 maxTime보다 커진 경우에 relocation 함수를 실행
// gird 데이터를 앞으로 이동시킨다.
