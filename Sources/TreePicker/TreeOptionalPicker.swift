//
//  TreeOptionalPicker.swift
//
//
//  Created by Boris Ovodov on 08.04.2024.
//

import Foundation
import SwiftUI

/// A control for selecting optional value from a set of hierarchical values.
///
/// You create a tree picker by providing a tree-structured data, `children` parameter that provides a key path to get the child nodes at any level, selection binding, a label, and a row content. Optionaly you can specify a view that represent empty selection value.
///
/// The following example shows how to create a tree picker with the tree of a `Location` type that conforms to `Identifiable` protocol:
///
/// ```swift
/// struct Location: Hashable, Identifiable {
///     let id = UUID()
///     var title: String
///     var children: [Location]?
/// }
///
/// private let locations: [Location] = [
///     .init(title: "🇬🇧 United Kingdom", children: [
///         .init(title: "London", children: nil),
///         .init(title: "Birmingham", children: nil),
///         .init(title: "Bristol", children: nil)
///     ]),
///     .init(title: "🇫🇷 France", children: [
///         .init(title: "Paris", children: nil),
///         .init(title: "Toulouse", children: nil),
///         .init(title: "Bordeaux", children: nil)
///     ]),
///     .init(title: "🇩🇪 Germany", children: [
///         .init(title: "Berlin", children: nil),
///         .init(title: "Hesse", children: [
///             .init(title: "Frankfurt", children: nil),
///             .init(title: "Darmstadt", children: nil),
///             .init(title: "Kassel", children: nil),
///         ]),
///         .init(title: "Hamburg", children: nil)
///     ]),
///     .init(title: "🇷🇺 Russia", children: nil)
/// ]
///
/// @State private var selection: UUID? = nil
///
/// var body: some View {
///     NavigationStack {
///         Form {
///             TreeOptionalPicker("Location", data: locations, children: \.children, selection: $selection) { location in
///                 Text(location.title)
///             }
///         }
///     }
/// }
/// ```
///
/// When select a row in a tree, depending on the type of `SelectionValue`, either the object itself became selection value or the value of it's identifier.
///
/// ### Selection methods
/// You can allow all nodes selection or only leaves. For this you need to specify `selectionMethod` parameter. By default parameter equal ``SelectionMethod/leafNodes`` value. It means that only node without children will be selectable. If choose ``SelectionMethod/nodes`` value, all nodes (include *folders*) will be selectable.
@available(macOS 13.0, iOS 16.0, visionOS 1.0, *)
@MainActor public struct TreeOptionalPicker<Label: View, SelectionValue: Hashable, Data: RandomAccessCollection, ID: Hashable, RowContent: View, EmptySelectionContent: View> : View {
    
    /// The data for populating the list.
    private var data: Data
    
    /// The key path to the data model's identifier.
    private var dataID: KeyPath<Data.Element, ID>
    
    /// A key path to a property whose value gives the children of `data`.
    private var children: KeyPath<Data.Element, Data?>
    
    /// A binding to a selected value.
    private var selection: Binding<SelectionValue?>
    
    /// The method of nodes selection in tree.
    private var selectionMethod: SelectionMethod
    
    /// A view builder that creates the view for a single row in pickers options.
    private var rowContent: (Data.Element) -> RowContent
    
    /// A view that describes the purpose of selecting an option.
    private var label: Label
    
    /// A view that represents an empty selection.
    private var emptySelectionContent: EmptySelectionContent
    
    /// The property that store options list state.
    @State private var isOptionsListDisplayed: Bool = false
    
    /// The content and behavior of the view.
    @MainActor public var body: some View {
#if os(iOS)
        NavigationLink {
            Form {
                OutlineGroup(self.data, id: self.dataID, children: self.children) { dataElement in
                    self.outlineGroupRow(dataElement)
                }
            }
        } label: {
            LabeledContent {
                self.selectedOption
            } label: {
                self.label
            }
        }
#elseif os(macOS)
        LabeledContent {
            Button(action: { self.openOptionsList() }, label: {
                HStack(spacing: 0) {
                    self.selectedOption
                    Spacer()
                    Image(systemName: "chevron.down.square.fill")
                        .padding(.trailing, -4)
                        .symbolRenderingMode(.multicolor)
                        .foregroundStyle(Color.accentColor)
                        .font(.body.bold())
                        .shadow(radius: 2)
                }
            })
            .popover(isPresented: self.$isOptionsListDisplayed) {
                OutlineGroup(self.data, id: self.dataID, children: self.children) { dataElement in
                    self.outlineGroupRow(dataElement)
                }
            }
        } label: {
            self.label
        }
#endif
    }
    
    @ViewBuilder private var selectedOption: some View {
        if let dataElement = self.selectedDataElement {
            self.rowContent(dataElement)
        } else {
            self.emptySelectionContent
        }
    }
    
    private var selectedDataElement: Data.Element? {
        if SelectionValue.self == Data.Element.self {
            return self.selection.wrappedValue as? Data.Element
        }
        
        if SelectionValue.self == ID.self {
            for dataElement in self.data {
                if let selectedDataElement = self.recursivelyFindSelectedDataElement(from: dataElement) {
                    return selectedDataElement
                }
            }
        }
        
        return nil
    }
    
    @ViewBuilder private func outlineGroupRow(_ dataElement: Data.Element) -> some View {
        if self.isSelectable(dataElement) {
            self.selectableRow(dataElement)
        } else {
            self.rowContent(dataElement)
        }
    }
    
    @ViewBuilder private func selectableRow(_ dataElement: Data.Element) -> some View {
        HStack {
            if self.isSelected(dataElement) {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.accentColor)
            }
            
            Button(action: { self.select(dataElement) }) {
                HStack {
                    self.rowContent(dataElement)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
    
    private func openOptionsList() {
        self.isOptionsListDisplayed = true
    }
    
    private func closeOptionsList() {
        self.isOptionsListDisplayed = false
    }
    
    private func recursivelyFindSelectedDataElement(from parent: Data.Element) -> Data.Element? {
        if parent[keyPath: self.dataID] as? SelectionValue == self.selection.wrappedValue {
            return parent
        }
        
        guard let children = parent[keyPath: self.children] else {
            return nil
        }
        
        for child in children {
            if let selectedDataElement = self.recursivelyFindSelectedDataElement(from: child) {
                return selectedDataElement
            }
        }
        
        return nil
    }
    
    private func isSelectable(_ dataElement: Data.Element) -> Bool {
        switch self.selectionMethod {
        case .leafNodes:
            if dataElement[keyPath: self.children] == nil {
                return true
            } else {
                return false
            }
        case .nodes:
            return true
        }
    }
    
    private func isSelected(_ dataElement: Data.Element) -> Bool {
        // If selection is `nil` then current `dataElement` isn't selected.
        guard let selection = self.selection.wrappedValue else {
            return false
        }
        
        // If selection has same type as `Data.Element` then compare selection and `Data.Element`.
        if let dataElement = dataElement as? SelectionValue {
            return dataElement == selection
        }
        
        // If selection has same type as `Data.Element.ID` then compare selection and `Data.Element.ID`.
        if let dataElementID = dataElement[keyPath: self.dataID] as? SelectionValue {
            return dataElementID == selection
        }
        
        // Return `false` if selection has different type or dataElement isn't selected.
        return false
    }
    
    private func select(_ dataElement: Data.Element) {
        if self.isSelected(dataElement) {
            self.selection.wrappedValue = nil
            return
        }
        
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

extension TreeOptionalPicker where Data.Element: Identifiable, ID == Data.Element.ID {
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select a single element. Picker generates its label from a localized string key.
    /// 
    /// - Parameters:
    ///   - titleKey: A localized string key that describes the purpose of selecting an option.
    ///   - data: The identifiable data for computing options.
    ///   - children: A key path to a property whose value gives the children of `data`.
    ///   - selection: A binding to a property that determines the currently-selected optional value.
    ///   - selectionMethod: The method of selecting options.
    ///   - rowContent: A view builder that creates the view for a single option.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectionMethod: SelectionMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Label == Text, EmptySelectionContent == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectionMethod = selectionMethod
        self.rowContent = rowContent
        self.emptySelectionContent = Text("emptySelectionDefaultTitle", bundle: .module)
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select a single element. Picker generates its label from a localized string key and displays a custom empty selection view.
    /// 
    /// - Parameters:
    ///   - titleKey: A localized string key that describes the purpose of selecting an option.
    ///   - data: The identifiable data for computing options.
    ///   - children: A key path to a property whose value gives the children of `data`.
    ///   - selection: A binding to a property that determines the currently-selected optional value.
    ///   - selectionMethod: The method of selecting options.
    ///   - rowContent: A view builder that creates the view for a single option.
    ///   - emptySelectionContent: A view that represents an empty selection.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectionMethod: SelectionMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder emptySelectionContent: () -> EmptySelectionContent) where Label == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectionMethod = selectionMethod
        self.rowContent = rowContent
        self.emptySelectionContent = emptySelectionContent()
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select a single element. Picker generates its label from a string.
    /// 
    /// - Parameters:
    ///   - title: A string that describes the purpose of selecting an option.
    ///   - data: The identifiable data for computing options.
    ///   - children: A key path to a property whose value gives the children of `data`.
    ///   - selection: A binding to a property that determines the currently-selected optional value.
    ///   - selectionMethod: The method of selecting options.
    ///   - rowContent: A view builder that creates the view for a single option.
    @MainActor public init<S>(_ title: S, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectionMethod: SelectionMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where S: StringProtocol, Label == Text, EmptySelectionContent == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectionMethod = selectionMethod
        self.rowContent = rowContent
        self.emptySelectionContent = Text("emptySelectionDefaultTitle", bundle: .module)
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select a single element. Picker generates its label from a string and displays a custom empty selection view.
    /// 
    /// - Parameters:
    ///   - title: A string that describes the purpose of selecting an option.
    ///   - data: The identifiable data for computing options.
    ///   - children: A key path to a property whose value gives the children of `data`.
    ///   - selection: A binding to a property that determines the currently-selected optional value.
    ///   - selectionMethod: The method of selecting options.
    ///   - rowContent: A view builder that creates the view for a single option.
    ///   - emptySelectionContent: A view that represents an empty selection.
    @MainActor public init<S>(_ title: S, data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectionMethod: SelectionMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder emptySelectionContent: () -> EmptySelectionContent) where S: StringProtocol, Label == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectionMethod = selectionMethod
        self.rowContent = rowContent
        self.emptySelectionContent = emptySelectionContent()
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select a single element. Picker displays a custom label.
    /// 
    /// - Parameters:
    ///   - data: The identifiable data for computing options.
    ///   - children: A key path to a property whose value gives the children of `data`.
    ///   - selection: A binding to a property that determines the currently-selected optional value.
    ///   - selectionMethod: The method of selecting options.
    ///   - rowContent: A view builder that creates the view for a single option.
    ///   - label: A view that describes the purpose of selecting an option.
    @MainActor public init(data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectionMethod: SelectionMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> Label) where EmptySelectionContent == Text {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectionMethod = selectionMethod
        self.rowContent = rowContent
        self.emptySelectionContent = Text("emptySelectionDefaultTitle", bundle: .module)
        self.label = label()
    }
    
    /// Creates a hierarchical picker that computes its options on demand from an underlying collection of identifiable data, optionally allowing users to select a single element. Picker displays a custom label and a custom empty selection view.
    /// 
    /// - Parameters:
    ///   - data: The identifiable data for computing options.
    ///   - children: A key path to a property whose value gives the children of `data`.
    ///   - selection: A binding to a property that determines the currently-selected optional value.
    ///   - selectionMethod: The method of selecting options.
    ///   - rowContent: A view builder that creates the view for a single option.
    ///   - label: A view that describes the purpose of selecting an option.
    ///   - emptySelectionContent: A view that represents an empty selection.
    @MainActor public init(data: Data, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectionMethod: SelectionMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> Label, @ViewBuilder emptySelectionContent: () -> EmptySelectionContent) {
        self.data = data
        self.dataID = \.id
        self.children = children
        self.selection = selection
        self.selectionMethod = selectionMethod
        self.rowContent = rowContent
        self.emptySelectionContent = emptySelectionContent()
        self.label = label()
    }
}

extension TreeOptionalPicker {
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select a single element. Picker generates its label from a localized string key.
    /// 
    /// - Parameters:
    ///   - titleKey: A localized string key that describes the purpose of selecting an option.
    ///   - data: The data for populating options.
    ///   - id: The key path to the data model's identifier.
    ///   - children: A key path to a property whose value gives the children of `data`.
    ///   - selection: A binding to a property that determines the currently-selected optional value.
    ///   - selectionMethod: The method of selecting options.
    ///   - rowContent: A view builder that creates the view for a single option.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectionMethod: SelectionMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Label == Text, EmptySelectionContent == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectionMethod = selectionMethod
        self.rowContent = rowContent
        self.emptySelectionContent = Text("emptySelectionDefaultTitle", bundle: .module)
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select a single element. Picker generates its label from a localized string key and displays a custom empty selection view.
    /// 
    /// - Parameters:
    ///   - titleKey: A localized string key that describes the purpose of selecting an option.
    ///   - data: The data for populating options.
    ///   - id: The key path to the data model's identifier.
    ///   - children: A key path to a property whose value gives the children of `data`.
    ///   - selection: A binding to a property that determines the currently-selected optional value.
    ///   - selectionMethod: The method of selecting options.
    ///   - rowContent: A view builder that creates the view for a single option.
    ///   - emptySelectionContent: A view that represents an empty selection.
    @MainActor public init(_ titleKey: LocalizedStringKey, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectionMethod: SelectionMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder emptySelectionContent: () -> EmptySelectionContent) where Label == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectionMethod = selectionMethod
        self.rowContent = rowContent
        self.emptySelectionContent = emptySelectionContent()
        self.label = Text(titleKey)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select a single element. Picker generates its label from a string.
    /// 
    /// - Parameters:
    ///   - title: A string that describes the purpose of selecting an option.
    ///   - data: The data for populating options.
    ///   - id: The key path to the data model's identifier.
    ///   - children: A key path to a property whose value gives the children of `data`.
    ///   - selection: A binding to a property that determines the currently-selected optional value.
    ///   - selectionMethod: The method of selecting options.
    ///   - rowContent: A view builder that creates the view for a single option.
    @MainActor public init<S>(_ title: S, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectionMethod: SelectionMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where S: StringProtocol, Label == Text, EmptySelectionContent == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectionMethod = selectionMethod
        self.rowContent = rowContent
        self.emptySelectionContent = Text("emptySelectionDefaultTitle", bundle: .module)
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select a single element. Picker generates its label from a string and displays a custom empty selection view.
    /// 
    /// - Parameters:
    ///   - title: A string that describes the purpose of selecting an option.
    ///   - data: The data for populating options.
    ///   - id: The key path to the data model's identifier.
    ///   - children: A key path to a property whose value gives the children of `data`.
    ///   - selection: A binding to a property that determines the currently-selected optional value.
    ///   - selectionMethod: The method of selecting options.
    ///   - rowContent: A view builder that creates the view for a single option.
    ///   - emptySelectionContent: A view that represents an empty selection.
    @MainActor public init<S>(_ title: S, data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectionMethod: SelectionMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder emptySelectionContent: () -> EmptySelectionContent) where S: StringProtocol, Label == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectionMethod = selectionMethod
        self.rowContent = rowContent
        self.emptySelectionContent = emptySelectionContent()
        self.label = Text(title)
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select a single element. Picker displays a custom label.
    /// 
    /// - Parameters:
    ///   - data: The data for populating options.
    ///   - id: The key path to the data model's identifier.
    ///   - children: A key path to a property whose value gives the children of `data`.
    ///   - selection: A binding to a property that determines the currently-selected optional value.
    ///   - selectionMethod: The method of selecting options.
    ///   - rowContent: A view builder that creates the view for a single option.
    ///   - label: A view that describes the purpose of selecting an option.
    @MainActor public init(data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectionMethod: SelectionMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> Label) where EmptySelectionContent == Text {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectionMethod = selectionMethod
        self.rowContent = rowContent
        self.emptySelectionContent = Text("emptySelectionDefaultTitle", bundle: .module)
        self.label = label()
    }
    
    /// Creates a hierarchical picker that identifies its options based on a key path to the identifier of the underlying data, optionally allowing users to select a single element. Picker displays a custom label and a custom empty selection view.
    /// 
    /// - Parameters:
    ///   - data: The data for populating options.
    ///   - id: The key path to the data model's identifier.
    ///   - children: A key path to a property whose value gives the children of `data`.
    ///   - selection: A binding to a property that determines the currently-selected optional value.
    ///   - selectionMethod: The method of selecting options.
    ///   - rowContent: A view builder that creates the view for a single option.
    ///   - label: A view that describes the purpose of selecting an option.
    ///   - emptySelectionContent: A view that represents an empty selection.
    @MainActor public init(data: Data, id: KeyPath<Data.Element, ID>, children: KeyPath<Data.Element, Data?>, selection: Binding<SelectionValue?>, selectionMethod: SelectionMethod = .leafNodes, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder label: () -> Label, @ViewBuilder emptySelectionContent: () -> EmptySelectionContent) {
        self.data = data
        self.dataID = id
        self.children = children
        self.selection = selection
        self.selectionMethod = selectionMethod
        self.rowContent = rowContent
        self.emptySelectionContent = emptySelectionContent()
        self.label = label()
    }
}
