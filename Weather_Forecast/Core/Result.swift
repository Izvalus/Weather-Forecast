//
//  Result.swift
//  
//
//  Created by Роман Мироненко on 22.10.2020.
//

import Foundation

enum Result<Success, Failure> where Failure: Error {
    case success(Success)
    case failure(Failure)
}

extension Result {
    @discardableResult
    func ifError(_ closure: (Failure) -> Void) -> Result {
        if case let .failure(error) = self {
            closure(error)
        }
        return self
    }
    
    @discardableResult
    func ifSuccess(_ closure: (Success) -> Void) -> Result {
        if case let .success(model) = self {
            closure(model)
        }
        return self
    }
}
