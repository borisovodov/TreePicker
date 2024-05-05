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
@MainActor public struct TreeMultiPicker<PickerLabel: View, SelectionValue: Hashable, Data: RandomAccessCollection, ID: Hashable, RowContent: View, NilSelectionContent: View> : View {
    
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
    
    /// A view that present `nil` selected value.
    private var nilSelectionContent: NilSelectionContent
    
    /// The content and behavior of the view.
    @MainActor public var body: some View {
        NavigationLink {
            Form {
                OutlineGroup(self.data, id: self.dataID, children: self.children) { dataElement in
                    self.outlineGroupRow(dataElement)
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
    
    @ViewBuilder private var selectedOptions: some View {
        if self.selectedDataElements.isEmpty {
            self.nilSelectionContent
        } else {
            VStack {
                ForEach(self.selectedDataElements, id: self.dataID) { dataElement in
                    self.rowContent(dataElement)
                }
            }
        }
    }
    
    private var selectedDataElements: [Data.Element] {
        var selection: [Data.Element] = []
        
        if SelectionValue.self == Data.Element.self {
            for selectedValue in self.selection.wrappedValue {
                if let selectedValue = selectedValue as? Data.Element {
                    selection.append(selectedValue)
                }
            }
            
            return selection
        }
        
        if SelectionValue.self == ID.self {
            for dataElement in self.data {
                self.recursivelyFindSelectedDataElement(from: dataElement, selection: &selection)
            }
            
            return selection
        }
        
        return selection
    }
    
    @ViewBuilder private func outlineGroupRow(_ dataElement: Data.Element) -> some View {
        Button(action: { self.select(dataElement) }) {
            HStack {
                self.selectionIndicator(dataElement)
                self.rowContent(dataElement)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder private func selectionIndicator(_ dataElement: Data.Element) -> some View {
        if self.isSelected(dataElement) {
            Label("????", systemImage: "checkmark")
                .labelStyle(.iconOnly)
        }
    }
    
    private func recursivelyFindSelectedDataElement(from parent: Data.Element, selection: inout [Data.Element]) {
        for selectedValue in self.selection.wrappedValue {
            if parent[keyPath: self.dataID] as? SelectionValue == selectedValue {
                selection.append(parent)
            }
        }
        
        guard let children = parent[keyPath: self.children] else {
            return
        }
        
        for child in children {
            self.recursivelyFindSelectedDataElement(from: child, selection: &selection)
        }
    }
    
    private func isSelected(_ dataElement: Data.Element) -> Bool {
        // If selection has same type as `Data.Element` then compare selection and `Data.Element`.
        if let dataElement = dataElement as? SelectionValue {
            return self.selection.wrappedValue.contains(dataElement)
        }
        
        // If selection has same type as `Data.Element.ID` then compare selection and `Data.Element.ID`.
        if let dataElementID = dataElement[keyPath: self.dataID] as? SelectionValue {
            return self.selection.wrappedValue.contains(dataElementID)
        }
        
        // Return `false` if selection has different type or dataElement isn't selected.
        return false
    }
    
    private func select(_ dataElement: Data.Element) {
        if self.isSelected(dataElement) {
            if let dataElement = dataElement as? SelectionValue {
                self.selection.wrappedValue.remove(dataElement)
                return
            }
            
            if let dataElementID = dataElement[keyPath: self.dataID] as? SelectionValue {
                self.selection.wrappedValue.remove(dataElementID)
                return
            }
        } else {
            if let dataElement = dataElement as? SelectionValue {
                self.selection.wrappedValue.insert(dataElement)
                return
            }
            
            if let dataElementID = dataElement[keyPath: self.dataID] as? SelectionValue {
                self.selection.wrappedValue.insert(dataElementID)
                return
            }
        }
    }
}

extension TreeMultiPicker where Data.Element: Identifiable, ID == Data.Element.ID {
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select multiple elements. Picker generates its label from a localized string key.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where PickerLabel == Text, NilSelectionContent == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilSelectionContent = Text(SupportingVariables.nilSelectionDefaultTitle, bundle: .module)
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select multiple elements. Picker generates its label from a localized string key and displays a custom empty selection view.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder nilSelectionContent: () -> NilSelectionContent) where PickerLabel == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilSelectionContent = nilSelectionContent()
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select multiple elements. Picker generates its label from a string.
    @MainActor public init<S>(_ title: S, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where S: StringProtocol, PickerLabel == Text, NilSelectionContent == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilSelectionContent = Text(SupportingVariables.nilSelectionDefaultTitle, bundle: .module)
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select multiple elements. Picker generates its label from a string and displays a custom empty selection view.
    @MainActor public init<S>(_ title: S, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder nilSelectionContent: () -> NilSelectionContent) where S: StringProtocol, PickerLabel == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilSelectionContent = nilSelectionContent()
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select multiple elements. Picker displays a custom label.
    @MainActor public init(data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> PickerLabel) where NilSelectionContent == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilSelectionContent = Text(SupportingVariables.nilSelectionDefaultTitle, bundle: .module)
        self.label = label()
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select multiple elements. Picker displays a custom label and a custom empty selection view.
    @MainActor public init(data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> PickerLabel, @ViewBuilder nilSelectionContent: () -> NilSelectionContent) {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilSelectionContent = nilSelectionContent()
        self.label = label()
    }
}

extension TreeMultiPicker {
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select multiple elements. Picker generates its label from a localized string key.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where PickerLabel == Text, NilSelectionContent == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilSelectionContent = Text(SupportingVariables.nilSelectionDefaultTitle, bundle: .module)
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select multiple elements. Picker generates its label from a localized string key and displays a custom empty selection view.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder nilSelectionContent: () -> NilSelectionContent) where PickerLabel == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilSelectionContent = nilSelectionContent()
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select multiple elements. Picker generates its label from a string.
    @MainActor public init<S>(_ title: S, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where S: StringProtocol, PickerLabel == Text, NilSelectionContent == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilSelectionContent = Text(SupportingVariables.nilSelectionDefaultTitle, bundle: .module)
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select multiple elements. Picker generates its label from a string and displays a custom empty selection view.
    @MainActor public init<S>(_ title: S, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder nilSelectionContent: () -> NilSelectionContent) where S: StringProtocol, PickerLabel == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilSelectionContent = nilSelectionContent()
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select multiple elements. Picker displays a custom label.
    @MainActor public init(data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> PickerLabel) where NilSelectionContent == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilSelectionContent = Text(SupportingVariables.nilSelectionDefaultTitle, bundle: .module)
        self.label = label()
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select multiple elements. Picker displays a custom label and a custom empty selection view.
    @MainActor public init(data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<Set<SelectionValue>>, selectingMethod: SelectingMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> PickerLabel, @ViewBuilder nilSelectionContent: () -> NilSelectionContent) {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectingMethod = selectingMethod
        self.rowContent = rowContent
        self.nilSelectionContent = nilSelectionContent()
        self.label = label()
    }
}
