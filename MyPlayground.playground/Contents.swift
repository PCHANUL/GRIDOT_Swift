import UIKit


func student(class: String) -> (String) -> Bool {
    return {_ in
        let input: (_ name: String) -> Bool = { name in
            print(name)
            return true
        }
    }
}

student(class: "ios")







