//
//  ViewController.swift
//  myFirebase
//
//  Created by 박찬울 on 2021/02/16.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    let db = Database.database().reference()
    var customers: [Customer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabel()
        saveBasicTypes()
        saveCustomers()
//        updateBasicTypes()
//        deleteBasicTypes()
        fetchCustomers()
    }
    
    func updateLabel() {
        db.child("firstData").observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? String ?? ""
            self.dataLabel.text = value
        }
    }
    
    @IBAction func createCustomer(_ sender: Any) {
        saveCustomers()
    }
    
    @IBAction func fetchCustomer(_ sender: Any) {
        fetchCustomers()
    }
    
    func updateCustomer() {
        guard customers.isEmpty == false else { return }
        customers[0].name = "min"
        
        let dictionary = customers.map { $0.toDictionary }
        db.updateChildValues(["customers": dictionary])
    }
    
    @IBAction func updateCustomer(_ sender: Any) {
        updateCustomer()
    }
    
    func deleteCustomer() {
        db.child("customers").removeValue()
    }
    
    @IBAction func deleteCustomer(_ sender: Any) {
        deleteCustomer()
    }
    
    
}

extension ViewController {
    func fetchCustomers() {
        db.child("customers").observeSingleEvent(of: .value) { snapshot in
            do {
                // String -> JSON type -> Model
                let data = try JSONSerialization.data(withJSONObject: snapshot.value, options: [])
                let decoder = JSONDecoder()
                let customers: [Customer] = try decoder.decode([Customer].self, from: data)
                self.customers = customers
                // Model -> View
                DispatchQueue.main.async {
                    self.countLabel.text = "\(customers.count)"
                }
            } catch let error {
                print("--> error: \(error.localizedDescription)")
            }
        }
    }
    
    func updateBasicTypes() {
        db.updateChildValues(["int": 6])
        db.updateChildValues(["double": 5.3])
        db.updateChildValues(["str": "변경된 스트링"])
    }
    
    func deleteBasicTypes() {
        db.child("int").removeValue()
        db.child("double").removeValue()
        db.child("str").removeValue()
    }
    
    
    
    
    func saveBasicTypes() {
        // Firebase child ("key").setValue(Value)
        // - string, number, dictionary, array
        db.child("int").setValue(3)
    }
    
    func saveCustomers() {
        // 책가게에서 사용자를 저장한다.
        // 모델 Customer + Book
        
        let books = [
            Book(title: "aaaaaaa", author: "someone"),
            Book(title: "bbbbbbb", author: "somebody"),
        ]
        
        let customer1 = Customer(id: "\(Customer.id)", name: "son", books: books)
        Customer.id += 1
        let customer2 = Customer(id: "\(Customer.id)", name: "kane", books: books)
        Customer.id += 1
        let customer3 = Customer(id: "\(Customer.id)", name: "dele", books: books)
        Customer.id += 1
        
        db.child("customers").child(customer1.id).setValue(customer1.toDictionary)
        db.child("customers").child(customer2.id).setValue(customer2.toDictionary)
        db.child("customers").child(customer3.id).setValue(customer3.toDictionary)
        
    }
}

struct Customer: Codable {
    let id: String
    var name: String
    let books: [Book]
    
    var toDictionary: [String: Any] {
        let booksArray = books.map { $0.toDictionary }
        let dict: [String: Any] = ["id": id, "name": name, "books": booksArray]
        return dict
    }
    
    static var id: Int = 0
}

struct Book: Codable {
    let title: String
    let author: String
    
    var toDictionary: [String: Any] {
        let dict: [String: Any] = ["title": title, "author": author]
        return dict
    }
}
