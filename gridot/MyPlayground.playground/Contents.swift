import UIKit

extension UInt16 {
    func printBits() {
        var i = 16

        while (i > 0) {
            i -= 1
            print(self >> i & 1, terminator: "")
        }
        print("")
    }

    mutating func setBitOff(_ location: Int) {
        self &= ~(1 << location)
    }

    mutating func setBitOn(_ location: Int) {
        self |= 1 << location
    }
}

var flag: [UInt16] = [0, 10]

flag[0].printBits()
flag[0].setBitOn(1)
flag[0].printBits()
flag[0].setBitOn(7)
flag[0].printBits()


flag[1].printBits()

let hex = "ffffff"
print(String(Int(hex, radix: 16)!, radix: 2))

print(




