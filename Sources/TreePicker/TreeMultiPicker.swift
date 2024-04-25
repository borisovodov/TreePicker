//
//  TreeMultiPicker.swift
//
//
//  Created by Boris Ovodov on 08.04.2024.
//

import Foundation
import SwiftUI


/// A control for selecting multiple options from a set of hierarchical values.
@available(macOS 14.0, iOS 17.0, visionOS 1.0, *)
@MainActor public struct TreeMultiPicker<PickerLabel: View, SelectionValue: Hashable, Data: RandomAccessCollection, ID: Hashable, RowContent: View> : View {
    
    /// Specifies the method of nodes selecting in tree.
    public enum SelectingMethod {
        /// Only leaf nodes of the tree are selectable.
        case leafNodes
        
        /// All tree nodes are independently selectable.
        case independent
        
        /// All tree nodes are selectable and selecting a node automatically selects all its child notes.
        case cascading
    }
    
    /// The data for populating the list.
    private var data: Data
    
    /// The key path to the data model's identifier.
    private var dataID: KeyPath<Data.Element, ID>
    
    /// A key path to a property whose non-`nil` value gives the children of `data`. A non-`nil` but empty value denotes a node capable of having children that is currently childless, such as an empty directory in a file system. On the other hand, if the property at the key path is `nil`, then `data` is treated as a leaf node in the tree, like a regular file in a file system.
    private var children: KeyPath<Data.Element, Data?>
    
    /// A binding to a set that identifies selected values.
    private var selection: Binding<Set<SelectionValue>>
    
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
                HStack {
                    Text("sdfsdfdfs")
                    Spacer()
                    self.rowContent(dataElement)
                }
            }
        } label: {
            LabeledContent {
                Text("тут выбранный элемент")
            } label: {
                self.label
            }
            .labeledContentStyle(.automatic)
        }
    }
}

extension TreeMultiPicker where Data.Element: Identifiable, ID == Data.Element.ID {
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select multiple elements. Picker generates its label from a localized string key.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where PickerLabel == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select multiple elements. Picker generates its label from a string.
    @MainActor public init<S>(_ title: S, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where S: StringProtocol, PickerLabel == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select multiple elements. Picker displays a custom label.
    @MainActor public init(data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> PickerLabel) {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.label = label()
    }
}

extension TreeMultiPicker {
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select multiple elements. Picker generates its label from a localized string key.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where PickerLabel == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select multiple elements. Picker generates its label from a string.
    @MainActor public init<S>(_ title: S, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where S: StringProtocol, PickerLabel == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select multiple elements. Picker displays a custom label.
    @MainActor public init(data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> PickerLabel) {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.label = label()
    }
}
