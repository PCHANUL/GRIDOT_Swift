import UIKit


let a = "#010203"



func getSubstring(str: String, from: Int, to: Int) -> String {
    let start = str.index(str.startIndex, offsetBy: from)
    let end = str.index(start, offsetBy: to - from)
    return String(str[start ..< end])
}

getSubstring(str: a, from: 1, to: 3)
getSubstring(str: a, from: 3, to: 5)

//print(String("e", radix: 10))

print(Int("A0", radix: 16)!)



