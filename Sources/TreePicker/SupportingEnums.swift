//
//  SupportingEnums.swift
//
//
//  Created by Boris Ovodov on 11.05.2024.
//

import Foundation

/// The method of nodes selection.
@frozen public enum SelectionMethod {
    
    /// The method in which only leaf nodes of the tree are selectable.
    case leafNodes
    
    /// The method in which all tree nodes are selectable.
    case nodes
}

/// The method of multiple nodes selection.
@frozen public enum MultiSelectionMethod {
    
    /// The method in which only leaf nodes of the tree are selectable.
    case leafNodes
    
    /// The method in which all tree nodes are independently selectable.
    case independent
    
    /// The method in which all tree nodes are selectable and selecting a node automatically selects all its child nodes.
    case cascading
}
