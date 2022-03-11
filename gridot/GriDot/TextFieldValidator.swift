//
//  TextFieldValidator.swift
//  GriDot
//
//  Created by 박찬울 on 2022/03/11.
//

import UIKit

enum ValidatorType {
    case name
    case email
}

func validateTextField(type: ValidatorType) -> Validator {
    switch type {
    case .name:
        return NameValidator()
    case .email:
        return EmailValidator()
    }
}

protocol Validator {
    func isValided(_ value: String) throws -> String
}

class ValidationError: Error {
    var msg: String
    
    init(_ msg: String) {
        self.msg = msg
    }
}

class NameValidator: Validator {
    func isValided(_ value: String) throws -> String {
        let pattern = "^[a-zA-Z0-9]*$"
        let range = NSRange(location: 0, length: value.count)
        
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            if (expression.firstMatch(in: value, options: [], range: range) == nil) {
                throw ValidationError("영문자와 숫자만 입력해주세요")
            }
        } catch {
            throw ValidationError("영문자와 숫자만 입력해주세요")
        }
        if (value.count < 5 || value.count > 30) {
            throw ValidationError("5자리 이상, 30자리 이하로 입력해주세요")
        }
        return value
    }
}

class EmailValidator: Validator {
    func isValided(_ value: String) throws -> String {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
        let range = NSRange(location: 0, length: value.count)
        
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            if (expression.firstMatch(in: value, options: [], range: range) == nil) {
                throw ValidationError("이메일 형식으로 입력해주세요")
            }
        } catch {
            throw ValidationError("이메일 형식으로 입력해주세요")
        }
        return value
    }
}
