import UIKit


func doit() {
    print("doit")
}


var a: () -> () { return true }

a = doit
a()
