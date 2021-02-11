import UIKit

struct Todo: Codable, Equatable {
    let id: Int
    var isDone: Bool
    var detail: String
    var isToday: Bool
    
    mutating func update(isDone: Bool, detail: String, isToday: Bool) {
        // [x] TODO: update 로직 추가
        self.isDone = isDone
        self.detail = detail
        self.isToday = isToday
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        // [x] TODO: 동등 조건 추가
        return lhs.isDone == rhs.isDone
    }
}

var todos: [Todo] = []

todos.append(Todo(id: 1, isDone: false, detail: "awefawef", isToday: true))
todos.append(Todo(id: 2, isDone: false, detail: "ㅐㅑㅈㅂㄷ규ㅜ", isToday: true))

func deleteTodo(_ todo: Todo) {
    print(todos.firstIndex(of: todo) ?? "none")
}

deleteTodo(Todo(id: 3, isDone: false, detail: "awefawef", isToday: true))









