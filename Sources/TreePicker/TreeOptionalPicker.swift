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
@MainActor public struct TreeOptionalPicker<PickerLabel: View, SelectionValue: Hashable, Data: RandomAccessCollection, ID: Hashable, RowContent: View, NilRowContent: View> : View {
    
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
    // TODO: Нужно посмотреть можем ли привязать это всё к одному дереву, чтобы не плодить отдельно single, optional и multi. Binding<Hashable?>.
    private var selection: Binding<SelectionValue?>
    
    /// The method of nodes selecting in tree.
    private var selectingMethod: SelectingMethod
    
    /// A view builder that creates the view for a single row in pickers options.
    private var rowContent: (Data.Element) -> RowContent
    
    /// A view that describes the purpose of selecting an option.
    private var label: PickerLabel
    
    /// A view for a row that present `nil` selected value.
    private var nilRowContent: NilRowContent
    
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
                self.selectedOptions
            } label: {
                self.label
            }
        }
    }
    
    private var selectedOptions: some View {
        Text("тут выбранный элемент")
    }
    
    private var isNoneSelected: Bool {
        return self.selection.wrappedValue == nil
    }
    
    @ViewBuilder private func selectionIndicator(_ dataElement: Data.Element) -> some View {
        if (self.isSelected(dataElement)) {
            Label("????", systemImage: "checkmark")
        } else {
            EmptyView()
        }
    }
    
    // CURRENT: всё хуета, нужно делать свои кастомные теги: https://medium.com/@Barbapapapps/beyond-basics-implementing-a-custom-picker-in-swiftui-88c01e283ac1
    // https://github.com/GeorgeElsham/TagExtractor/tree/main
    private func isSelected(_ dataElement: Data.Element) -> Bool {
        // If selection is `nil` then current `dataElement` isn't selected.
        guard let selection = self.selection.wrappedValue else {
            print("~~~nil")
            return false
        }
        
        // If selection has same type as `Data.Element` then compare selection and `Data.Element`.
        if selection is Data.Element {
            print("~~~selection is Data.Element")
            return dataElement as? SelectionValue == selection
        }
        
        // If selection has same type as `Data.Element.ID` then compare selection and `Data.Element.ID`.
        if selection is ID {
            print("~~~selection is ID")
            return dataElement[keyPath: self.dataID] as? SelectionValue == selection
        }
        
        // Return `false` if selection has different type or dataElement isn't selected.
        print("~~~false")
        return false
    }
    
    private var isNilElementSelected: Bool {
        guard let _ = self.selection.wrappedValue else { return true }
        
        return false
    }
    
    private func select(_ dataElement: Data.Element) {
        // тут nil если пусто.
        if self.selection.wrappedValue is Data.Element {
            print("~~~selection is Data.Element in select")
            self.selection.wrappedValue = self.isSelected(dataElement) ? nil : dataElement as? SelectionValue
        }
        
        if self.selection.wrappedValue is ID {
            print("~~~selection is ID in select")
            self.selection.wrappedValue = self.isSelected(dataElement) ? nil : dataElement[keyPath: self.dataID] as? SelectionValue
        }
        print("~~~nil")
        self.selection.wrappedValue = nil
    }
}

extension TreeOptionalPicker where Data.Element: Identifiable, ID == Data.Element.ID {
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select a single element. Picker generates its label from a localized string key.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where PickerLabel == Text, NilRowContent == Text {
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
    @MainActor public init<S>(_ title: S, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where S: StringProtocol, PickerLabel == Text, NilRowContent == Text {
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
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder nilRowContent: () -> NilRowContent) where PickerLabel == Text {
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
    @MainActor public init<S>(_ title: S, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder nilRowContent: () -> NilRowContent) where S: StringProtocol, PickerLabel == Text {
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
    @MainActor public init(data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> PickerLabel) where NilRowContent == Text {
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
    @MainActor public init(data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> PickerLabel, @ViewBuilder nilRowContent: () -> NilRowContent) {
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
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where PickerLabel == Text, NilRowContent == Text {
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
    @MainActor public init<S>(_ title: S, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where S: StringProtocol, PickerLabel == Text, NilRowContent == Text {
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
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder nilRowContent: () -> NilRowContent) where PickerLabel == Text {
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
    @MainActor public init<S>(_ title: S, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder nilRowContent: () -> NilRowContent) where S: StringProtocol, PickerLabel == Text {
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
    @MainActor public init(data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> PickerLabel) where NilRowContent == Text {
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
    @MainActor public init(data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> PickerLabel, @ViewBuilder nilRowContent: () -> NilRowContent) {
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
