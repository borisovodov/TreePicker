//
//  TreeOptionalPicker.swift
//
//
//  Created by Boris Ovodov on 08.04.2024.
//

import Foundation
import SwiftUI


/// A control for selecting single option from a set of hierarchical values.
@available(macOS 14.0, iOS 17.0, visionOS 1.0, *)
@MainActor public struct TreeOptionalPicker<Label: View, SelectionValue: Hashable, Data: RandomAccessCollection, ID: Hashable, Content: View, RowContent: View, NilRowContent: View> : View {
    
    /// Specifies the method of nodes selecting in tree.
    public enum SelectingMethod {
        /// Only leaf nodes of the tree are selectable.
        case leafNodes
        
        /// All tree nodes are selectable.
        case nodes
    }
    
    /// Default title for `nil` row view.
    private let nilRowDefaultTitle: LocalizedStringKey = "nilRowDefaultTitle"
    
    /// The data for populating the list.
    private var data: Data
    
    /// The key path to the data model's identifier.
    private var dataID: KeyPath<Data.Element, ID>
    
    /// A key path to a property whose non-`nil` value gives the children of `data`. A non-`nil` but empty value denotes a node capable of having children that is currently childless, such as an empty directory in a file system. On the other hand, if the property at the key path is `nil`, then `data` is treated as a leaf node in the tree, like a regular file in a file system.
    private var children: KeyPath<Data.Element, Data?>
    
    /// A binding to a selected value.
    private var selection: Binding<SelectionValue?>
    
    /// The method of nodes selecting in tree.
    private var selectingMethod: SelectingMethod
    
    /// A view builder that creates the view for a single row in pickers options.
    private var rowContent: (Data.Element) -> RowContent
    
    /// A view that describes the purpose of selecting an option.
    private var label: Label
    
    /// A view for a row that present `nil` selected value.
    private var nilRowContent: NilRowContent
    
    /// The content and behavior of the view.
    @MainActor public var body: some View {
        OutlineGroup(self.data, id: self.dataID, children: self.children) { dataElement in
            VStack {
                Text("sdfsdfdfs")
                self.rowContent(dataElement)
            }
        }
    }
}

extension TreeOptionalPicker where Data.Element: Identifiable, ID == Data.Element.ID {
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select a single element. Picker generates its label from a localized string key.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Label == Text, NilRowContent == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilRowContent = Text(self.nilRowDefaultTitle)
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select a single element. Picker generates its label from a string.
    @MainActor public init<S>(_ title: S, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where S: StringProtocol, Label == Text, NilRowContent == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilRowContent = Text(self.nilRowDefaultTitle)
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select a single element. Picker generates its label from a localized string key and displays a custom clear selection row.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder nilRowContent: () -> NilRowContent) where Label == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilRowContent = nilRowContent()
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select a single element. Picker generates its label from a string and displays a custom clear selection row.
    @MainActor public init<S>(_ title: S, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder nilRowContent: () -> NilRowContent) where S: StringProtocol, Label == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilRowContent = nilRowContent()
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select a single element. Picker displays a custom label.
    @MainActor public init(data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> Label) where NilRowContent == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilRowContent = Text(self.nilRowDefaultTitle)
        self.label = label()
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select a single element. Picker displays a custom label and a custom clear selection row.
    @MainActor public init(data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> Label, @ViewBuilder nilRowContent: () -> NilRowContent) {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilRowContent = nilRowContent()
        self.label = label()
    }
}

extension TreeOptionalPicker {
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select a single element. Picker generates its label from a localized string key.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Label == Text, NilRowContent == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilRowContent = Text(self.nilRowDefaultTitle)
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select a single element. Picker generates its label from a string.
    @MainActor public init<S>(_ title: S, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where S: StringProtocol, Label == Text, NilRowContent == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilRowContent = Text(self.nilRowDefaultTitle)
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select a single element. Picker generates its label from a localized string key and displays a custom clear selection row.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder nilRowContent: () -> NilRowContent) where Label == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilRowContent = nilRowContent()
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select a single element. Picker generates its label from a string and displays a custom clear selection row.
    @MainActor public init<S>(_ title: S, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder nilRowContent: () -> NilRowContent) where S: StringProtocol, Label == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilRowContent = nilRowContent()
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select a single element. Picker displays a custom label.
    @MainActor public init(data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> Label) where NilRowContent == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilRowContent = Text(self.nilRowDefaultTitle)
        self.label = label()
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select a single element. Picker displays a custom label and a custom clear selection row.
    @MainActor public init(data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> Label, @ViewBuilder nilRowContent: () -> NilRowContent) {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilRowContent = nilRowContent()
        self.label = label()
    }
}
