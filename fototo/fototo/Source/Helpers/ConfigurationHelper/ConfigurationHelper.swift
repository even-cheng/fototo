//
//  ConfigurationHelper.swift
//  TestCollectionView
//
//  Created by Even_cheng on 06/21/19.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import Foundation

internal func Init<Type>(_ value: Type, block: (_ object: Type) -> Void) -> Type {
    block(value)
    return value
}
