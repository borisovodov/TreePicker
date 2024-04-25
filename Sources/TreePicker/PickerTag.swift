//
//  TreePickerTag.swift
//
//
//  Created by Boris Ovodov on 25.04.2024.
//

import Foundation
import SwiftUI

@usableFromInline internal struct PickerTag<V: Hashable> : _ViewTraitKey {
    @usableFromInline @frozen enum Value {
      case untagged
      case tagged(V)
    }
    
    @inlinable static var defaultValue: PickerTag<V>.Value {
      return .untagged
    }
}

extension View {
    /// Sets the unique tag value of this view.
    @inlinable public func pickerTag<V>(_ tag: V) -> some View where V : Hashable {
        return _trait(PickerTag<V>.self, .tagged(tag))
    }
}
