//
//  Previews.swift
//
//
//  Created by Boris Ovodov on 17.04.2024.
//

import Foundation
import SwiftUI

#if DEBUG
struct Location: Hashable, Identifiable {
    let id = UUID()
    var title: String
    var children: [Location]?
}

private let locations: [Location] = [
    .init(title: "🇬🇧 United Kingdom", children: [
        .init(title: "London", children: nil),
        .init(title: "Birmingham", children: nil),
        .init(title: "Bristol", children: nil)
    ]),
    .init(title: "🇫🇷 France", children: [
        .init(title: "Paris", children: nil),
        .init(title: "Toulouse", children: nil),
        .init(title: "Bordeaux", children: nil)
    ]),
    .init(title: "🇩🇪 Germany", children: [
        .init(title: "Berlin", children: nil),
        .init(title: "Hesse", children: [
            .init(title: "Frankfurt", children: nil),
            .init(title: "Darmstadt", children: nil),
            .init(title: "Kassel", children: nil),
        ]),
        .init(title: "Hamburg", children: nil)
    ]),
    .init(title: "🇷🇺 Russia", children: nil)
]

#Preview("TreeSinglePicker") {
    TreeSinglePickerPreview()
}

#Preview("TreeOptionalPicker") {
    TreeOptionalPickerPreview()
}

#Preview("TreeMultiPicker") {
    TreeMultiPickerPreview()
}

#Preview("List") {
    ListPreview()
}

#Preview("Picker") {
    PickerPreview()
}

struct TreeSinglePickerPreview: View {
    @State private var selection: Location = locations[3]
    @State private var selectionID: String = "🇷🇺 Russia"
    
    var body: some View {
        NavigationStack {
            Form {
                TreeSinglePicker("Location", data: locations, children: \.children, selection: $selection) { location in
                    Text(location.title)
                }
            }
        }
    }
}

struct TreeOptionalPickerPreview: View {
    @State private var selection: Location? = nil
    @State private var selectionID: String? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                TreeOptionalPicker("Location", data: locations, children: \.children, selection: $selectionID) { location in
                    Text(location.title)
                }
            }
        }
    }
}

struct TreeMultiPickerPreview: View {
    @State private var multiSelection: Set<Location> = []
    @State private var multiSelectionID: Set<String> = []
    
    var body: some View {
        NavigationStack {
            Form {
                TreeMultiPicker("Locations", data: locations, children: \.children, selection: $multiSelection, selectionMethod: .cascading) { location in
                    Text(location.title)
                }
            }
        }
    }
}

struct ListPreview: View {
    @State private var selection: Location? = nil
    @State private var selectionSingle: Location = .init(title: "🇷🇺 Russia", children: nil)
    @State private var multiSelection: Set<Location> = []
    @State private var selectionID: String? = nil
    @State private var selectionIDSingle: String = ""
    @State private var multiSelectionID: Set<String> = []
    
    var body: some View {
        NavigationStack {
            Form {
                NavigationLink {
                    List(locations, children: \.children, selection: $selectionID) { selectedDataElement in
                        HStack {
                            Text(selectedDataElement.title)
                        }
                        .tag(selectedDataElement)
                    }
                    #if !os(macOS)
                    .toolbar { EditButton() }
                    #endif
                } label: {
                    LabeledContent {
                        Text(selectionID ?? "nil")
//                        ForEach(Array(selectionsID), id: \.self) { selection in
//                            Text(selection)
//                        }
                    } label: {
                        Text("Locations")
                    }
                }
            }
        }
    }
}

struct PickerPreview: View {
    @State private var selection: Location = .init(title: "🇷🇺 Russia", children: nil)
    @State private var selectionID: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Location", selection: $selectionID) {
                    ForEach(locations, id: \.title) { location in
                        Text(location.title)
                    }
                }
                #if !os(macOS)
                .pickerStyle(.navigationLink)
                #endif
            }
        }
    }
}
#endif
