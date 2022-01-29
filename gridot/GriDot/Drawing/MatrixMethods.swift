//
//  MatrixMethods.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/19.
//

import UIKit

extension Int32 {
    func printBits() {
        var i = 16

        while (i > 0) {
            i -= 1
            print(self >> i & 1, terminator: "")
        }
        print("")
    }
    
    func getBitStatus(_ location: Int) -> Bool {
        return ((self >> location & 1) == 1)
    }

    mutating func setBitOff(_ location: Int) {
        self &= ~(1 << location)
    }

    mutating func setBitOn(_ location: Int) {
        self |= 1 << location
    }
}

func matrixToUInt32(_ grid: [String: [Int: [Int]]]) -> [Int32] {
    // [hex: [x: [y]]] -> [Int32]
    // 음수를 사용하면 각 요소를 분리하거나, 요소의 타입을 알려줄 수 있다.
    // 음수가 아닌 경우에는 비트를 확인하는데 16비트까지 사용한다.
    // [-1, hex, -16, gridData, -1, hex, -16, gridData]
    // -1 뒤에 있는 Int32는 hex, -16 뒤에 있는 Int32는 grid이다.
    //
    var data: [Int32] = []

    for (hex, xDir) in grid {
        let (r, g, b) = hex.rgb32!
        
        data.append(-1)
        data.append(contentsOf: [r, g, b])
        data.append(-16)
        
        for x in 0..<16 {
            var ele: Int32 = 0
            if (xDir[x] != nil) {
                for y in xDir[x]! {
                    ele.setBitOn(y)
                }
            }
            data.append(ele)
        }
    }
    return data
}


func matrixToString(grid: [String: [Int: [Int]]]) -> String {
    // [color: [Int: [Int]]]
    // 정수는 16진수로 변환된다.
    // #ffffff 9:1234 6:123acb3 7:123abcac #00ffff 형식으로 문자열을 정리한다.
    // y를 정렬하여 같은 y를 가진 x를 하나로 묶는다.
    // 정렬된 x, y에서 연속되는 경우를 찾아 대쉬(-)로 묶는다.
    var result: String = ""
    for hex in grid.keys {
        var colorLocations: [String: [Int]] = [:]
        
        for x in grid[hex]!.keys {
            var yGrid = grid[hex]![x]!
            
            // y위치를 16진수로 변환하며 하나의 문자열로 바꾼다.
            let yLocations: String = shortenString(&yGrid)
            
            // 같은 y위치 문자열을 가진 배열을 찾아 넣는다.
            if colorLocations[yLocations] == nil{
                colorLocations[yLocations] = [x]
            } else {
                colorLocations[yLocations]?.append(x)
            }
        }
        var locationStr: String = ""
        
        // y위치를 기준으로 모인 x배열들을 문자열로 변환한다.
        for strY in colorLocations.keys {
            var array = colorLocations[strY]!
            // location과 array.joined()에서 연속된 수를 처리
            locationStr += " \(shortenString(&array)):\(strY)"
        }
        result += "\(hex)\(locationStr) "
    }
    return result
}

func shortenString(_ array: inout [Int]) -> String {
    // 연속되는 수를 확인하여 생략된 문자열을 출력합니다.
    array.sort()
    let initValue = array[0]
    var dir: [String: Int] = ["start": initValue, "end": initValue]
    var result: String = ""
    
    for i in 1..<array.count {
        let value = array[i]
        if dir["end"]! + 1 == value {
            dir["end"] = value
        } else {
            let start = dir["start"]!
            let end = dir["end"]!
            result = shorten(start: start, end: end, str: result)
            dir = ["start": value, "end": value]
        }
    }
    result = shorten(start: dir["start"]!, end: dir["end"]!, str: result)
    return result
}
 
func shorten(start: Int, end: Int, str: String) -> String {
    var result = str
    if end - start < 2 {
        for j in start...end {
            result += String(j, radix: 16)
        }
    } else {
        let start = String(start, radix: 16)
        let end = String(end, radix: 16)
        result += "\(start)-\(end)"
    }
    return result
}


func stringToMatrix(_ string: String) -> [String:[Int: [Int]]] {
    // [x] 띄어쓰기를 기준으로 문자열을 나눈다.
    // [x] '#'으로 색상과 좌표를 나눈다. [색상: [좌표]]
    // [x] 좌표 문자열을 ':'의 앞부분을 키를 만들고 뒷부분을 값으로 넣는다. [색상: [앞: [뒤]]]
    // [x] '-'를 해석할 함수를 작성
    let splited = string.split(separator: " ")
    var resultDic: [String:[Int: [Int]]] = [:]
    var key: String!
    
    splited.forEach { item in
        if (item == "none") { return }
        if item.contains("#") {
            resultDic[String(item)] = [:]
            key = String(item)
        } else {
            let locations = item.split(separator: ":")
            let xLocations = locations[0]
            let yLocations = locations[1]
            
            // [x] "-" 축약 해제
            // [x] y배열 생성
            // [x] [x : [y]] 생성
            var yArray: [Int] = []
            for y in 0..<yLocations.count {
                let index = yLocations.index(yLocations.startIndex, offsetBy: y)
                if yLocations[index] == "-" {
                    // array 마지막 값과 다음 인덱스 값의 사이 값을 생성
                    let start = yArray.last! + 1
                    let endIndex = yLocations.index(yLocations.startIndex, offsetBy: y+1)
                    let end = Int(String(yLocations[endIndex]), radix: 16)!
                    for i in start..<end {
                        yArray.append(i)
                    }
                } else {
                    let newY = Int(String(yLocations[index]), radix: 16)!
                    yArray.append(newY)
                }
            }
            
            for x in 0..<xLocations.count {
                let index = xLocations.index(xLocations.startIndex, offsetBy: x)
                if xLocations[index] == "-" {
                    let startIndex = xLocations.index(xLocations.startIndex, offsetBy: x-1)
                    let endIndex = xLocations.index(xLocations.startIndex, offsetBy: x+1)
                    let start = Int(String(xLocations[startIndex]), radix: 16)!
                    let end = Int(String(xLocations[endIndex]), radix: 16)!
                    for i in start+1..<end {
                        resultDic[key]![i] = yArray
                    }
                } else {
                    let newX = Int(String(xLocations[index]), radix: 16)!
                    resultDic[key]![newX] = yArray
                }
            }
        }
    }
    return resultDic
}
