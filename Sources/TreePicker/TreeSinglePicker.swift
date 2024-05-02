//
//  TreeSinglePicker.swift
//
//
//  Created by Boris Ovodov on 13.04.2024.
//

import Foundation
import SwiftUI


/// A control for selecting exactly one option from a set of hierarchical values.
@available(macOS 14.0, iOS 17.0, visionOS 1.0, *)
@MainActor public struct TreeSinglePicker<PickerLabel: View, SelectionValue: Hashable, Data: RandomAccessCollection, ID: Hashable, RowContent: View> : View {
    
    /// Specifies the method of nodes selecting in tree.
    public enum SelectingMethod {
        /// Only leaf nodes of the tree are selectable.
        case leafNodes
        
        /// All tree nodes are selectable.
        case nodes
    }
    
    /// The data for populating the list.
    private var data: Data
    
    /// The key path to the data model's identifier.
    private var dataID: KeyPath<Data.Element, ID>
    
    /// A key path to a property whose non-`nil` value gives the children of `data`. A non-`nil` but empty value denotes a node capable of having children that is currently childless, such as an empty directory in a file system. On the other hand, if the property at the key path is `nil`, then `data` is treated as a leaf node in the tree, like a regular file in a file system.
    private var children: KeyPath<Data.Element, Data?>
    
    /// A binding to a non optional selected value.
    private var selection: Binding<SelectionValue>
    
    /// The method of nodes selecting in tree.
    private var selectingMethod: SelectingMethod
    
    /// A view builder that creates the view for a single row in pickers options.
    private var rowContent: (Data.Element) -> RowContent
    
    /// A view that describes the purpose of selecting an option.
    private var label: PickerLabel
    
    /// The content and behavior of the view.
    @MainActor public var body: some View {
        NavigationLink {
            OutlineGroup(self.data, id: self.dataID, children: self.children) { dataElement in
                Button(action: { self.select(dataElement) }) {
                    HStack {
                        self.selectionIndicator(dataElement)
                        self.rowContent(dataElement)
                    }
                }
            }
        } label: {
            LabeledContent {
                self.selectedOption
            } label: {
                self.label
            }
        }
    }
    
    @ViewBuilder private var selectedOption: some View {
        if let dataElement = self.dataElement {
            self.rowContent(dataElement)
            
        } else {
            EmptyView()
        }
    }
    
    private var dataElement: Data.Element? {
        if SelectionValue.self == Data.Element.self {
            return self.selection.wrappedValue as? Data.Element
        }
        
        if SelectionValue.self == ID.self {
            // https://stackoverflow.com/questions/32301336/swift-recursively-cycle-through-all-subviews-to-find-a-specific-class-and-appen
            #warning("Не работает выбор города при текстовом селекте. Выбор страны работает, а города нет. Видимо проблема во вложенном поиске.")
//            _ = self.data.filter { dataElement in
//                return dataElement[keyPath: self.dataID] as? SelectionValue == self.selection.wrappedValue
//            }
            
            return self.data.first(where: { dataElement in
                return dataElement[keyPath: self.dataID] as? SelectionValue == self.selection.wrappedValue
            })
        }
        
        return nil
    }
    
    @ViewBuilder private func selectionIndicator(_ dataElement: Data.Element) -> some View {
        if (self.isSelected(dataElement)) {
            Label("????", systemImage: "checkmark")
                .labelStyle(.iconOnly)
        } else {
            EmptyView()
        }
    }
    
    private func isSelected(_ dataElement: Data.Element) -> Bool {
        // If selection has same type as `Data.Element` then compare selection and `Data.Element`.
        if let dataElement = dataElement as? SelectionValue {
            return dataElement == self.selection.wrappedValue
        }
        
        // If selection has same type as `Data.Element.ID` then compare selection and `Data.Element.ID`.
        if let dataElementID = dataElement[keyPath: self.dataID] as? SelectionValue {
            return dataElementID == self.selection.wrappedValue
        }
        
        // Return `false` if selection has different type or dataElement isn't selected.
        return false
    }
    
    private func select(_ dataElement: Data.Element) {
        if let dataElement = dataElement as? SelectionValue {
            self.selection.wrappedValue = dataElement
            return
        }
        
        if let dataElementID = dataElement[keyPath: self.dataID] as? SelectionValue {
            self.selection.wrappedValue = dataElementID
            return
        }
    }
}

extension TreeSinglePicker where Data.Element: Identifiable, ID == Data.Element.ID {
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data and allowing users to have exactly one option always selected. Picker generates its label from a localized string key.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where PickerLabel == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data and allowing users to have exactly one option always selected. Picker generates its label from a string.
    @MainActor public init<S>(_ title: S, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where S: StringProtocol, PickerLabel == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data and allowing users to have exactly one option always selected. Picker displays a custom label.
    @MainActor public init(data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> PickerLabel) {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.label = label()
    }
}

extension TreeSinglePicker {
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data and allowing users to have exactly one option always selected. Picker generates its label from a localized string key.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where PickerLabel == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data and allowing users to have exactly one option always selected. Picker generates its label from a string.
    @MainActor public init<S>(_ title: S, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where S: StringProtocol, PickerLabel == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data and allowing users to have exactly one option always selected. Picker displays a custom label.
    @MainActor public init(data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> PickerLabel) {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.label = label()
    }
}
