//
//  Functions.swift
//  Weather_Forecast
//
//  Created by Роман Мироненко on 23.10.2020.
//  Copyright © 2020 Роман Мироненко. All rights reserved.
//

func setup<Type>(_ object: Type, block: (Type) -> Void) -> Type {
    block(object)
    return object
}
