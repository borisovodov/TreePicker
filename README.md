# TreePicker

A pack of SwiftUI tree pickers that provide selecting options from hierarchical data. Pickers work on iOS, iPadOS and visionOS. Library hasn't third-party dependencies.

![TreeMultiPicker example](Documentation/iOS-1.png)

[![Latest release](https://img.shields.io/github/v/release/borisovodov/TreePicker)](https://github.com/borisovodov/TreePicker/releases)
[![Build and test status](https://github.com/borisovodov/TreePicker/actions/workflows/workflow.yaml/badge.svg)](https://github.com/borisovodov/TreePicker/actions/workflows/workflow.yaml)
[![Code coverage status](https://img.shields.io/codecov/c/github/borisovodov/TreePicker)](https://codecov.io/gh/borisovodov/TreePicker)
![Lowest supported iOS version](https://img.shields.io/badge/iOS-16+-blue)
![Lowest supported visionOS version](https://img.shields.io/badge/visionOS-1+-blue)

## Features

`TreePicker` package has several tree pickers for different selection value: exactly one selected value, optional value and set of values. Use `TreeSinglePicker`, `TreeOptionalPicker` and `TreeMultiPicker` respectively.

Work with hierarchical data, it's children and selection is similar to SwiftUI hierarchical `List`. Additionaly you can specify selection method. Next methods available:
* Only leaves (nodes without children) are selectable.
* All nodes (include *folders*) are selectable.
* All nodes are selectable and selecting a node automatically selects all its child nodes. This method is available for `TreeMultiPicker` only.

## Installation

### In Xcode

Open `.xcproject` file → click `PROJECT` → `Package Dependencies` → `+` → type `https://github.com/borisovodov/TreePicker` in the search field → click `Add Package`

After that add `import TreePicker` in your source code.

## Usage

You create a tree picker by providing a tree-structured data, `children` parameter that provides a key path to get the child nodes at any level, selection binding, a label that describes the purpose of selecting an option and a row content. For `TreeOptionalPicker` and `TreeMultiPicker` you can specify a view that represent empty selection value.

The following example shows how to create a tree picker with the tree of a `Location` type that conforms to `Identifiable` protocol. Picker provide multiple selection.

```swift
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

@State private var multiSelection: Set<UUID> = []

var body: some View {
    NavigationStack {
        Form {
            TreeMultiPicker("Location", data: locations, children: \.children, selection: $multiSelection) { location in
                Text(location.title)
            }
        }
    }
}
```

[//]: # (Выглядеть на гифах это будет вот так на iOS.)

If `data` doesn't conform `Identifable` protocol when you can specify key path to hashable identifier through `id` parameter. For example for `Location` like this:

```swift
struct Location: Hashable {
    var title: String
    var children: [Location]?
}
```

you need to use initializer with `id` parameter:

```swift
TreeMultiPicker("Location", data: locations, id: \.title, children: \.children, selection: $multiSelection) { location in
    Text(location.title)
}
```

### Selection value

When select a row in a tree, depending on the type of `SelectionValue`, either the object itself became selection value or the value of it's identifier.

### Selection methods

You can allow all nodes selection or only leaves. For this you need to specify `selectionMethod` parameter. By default parameter equal `leafNodes` value. It means that only node without children will be selectable. If choose `nodes` value (`independent` for `TreeMultiPicker`), all nodes (include *folders*) will be selectable. For cascading selection of option children in `TreeMultiPicker` you need to use `cascading` value. Create multi picker with cascading selection method for example:

```swift
TreeMultiPicker("Location", data: locations, children: \.children, selection: $multiSelection, selectionMethod: .cascading) { location in
    Text(location.title)
}
```

[//]: # (Выглядеть на гифах это будет вот так на iOS.)
