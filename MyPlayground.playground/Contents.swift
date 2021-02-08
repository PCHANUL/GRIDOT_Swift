import UIKit

struct Grade {
    var letter: Character
    var points: Double
    var credits: Double
}

class Person {
    var firstName: String
    var lastName: String
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    func printMyName() {
        print("My name is \(firstName) \(lastName)")
    }
}

class Student: Person {
    var grades: [Grade] = []
}

let jay = Person(firstName: "Jay", lastName: "Lee")
let jason = Student(firstName: "Jason", lastName: "Lee")

let math = Grade(letter: "B", points: 8.5, credits: 3)
jason.grades.append(math)

jason.grades.count

class StudentAthelete: Student {
    var trainedTime: Int = 0
    
    func train() {
        trainedTime += 1
    }
}

class FootballPlayer: StudentAthelete {
    override func train() {
        trainedTime += 2
    }
}

// Person > Student > StudentAthelete > FootballPlayer

var athelete1 = StudentAthelete(firstName: "nang", lastName: "lee")
var athelete2 = FootballPlayer(firstName: "asdf", lastName: "lee")

athelete1.train()
athelete2.train()

athelete1.trainedTime
athelete2.trainedTime









