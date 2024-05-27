//
//  SupportingFunctions.swift
//
//
//  Created by Boris Ovodov on 14.05.2024.
//

import Foundation

internal func recursivelyHandleDataElementAndChildren<Data>(from parent: Data.Element, children childrenID: KeyPath<Data.Element, Data?>, action: (Data.Element) -> Void) where Data : RandomAccessCollection {
    action(parent)
    
    guard let children = parent[keyPath: childrenID] else {
        return
    }
    
    for child in children {
        recursivelyHandleDataElementAndChildren(from: child, children: childrenID) { child in
            action(child)
        }
    }
}
