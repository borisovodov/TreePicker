# Getting Started

Create tree pickers.

## Installation

Add next row in your `Package.swift` file `dependencies` section:

`.package(url: "https://github.com/borisovodov/TreePicker.git", from: "0.1.0")`.

Alternatively you can add package dependency in Xcode. For that open `.xcproject` file → click `PROJECT` → `Package Dependencies` → `+` → type `https://github.com/borisovodov/TreePicker` in the search field → click `Add Package`. See the Xcode [documentation](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) for details.

## Usage

First things first: add `import TreePicker` in your source code.

You create a tree picker by providing a tree-structured data, `children` parameter that provides a key path to get the child nodes at any level, selection binding, a label that describes the purpose of selecting an option and a row content. For ``TreeOptionalPicker`` and ``TreeMultiPicker`` you can specify a view that represent empty selection value.

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

![TreeMultiPicker on iOS example](iOS-2.gif)

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

You can allow all nodes selection or only leaves. For this you need to specify `selectionMethod` parameter. By default parameter equal ``SelectionMethod/leafNodes`` value (``MultiSelectionMethod/leafNodes`` for ``TreeMultiPicker``). It means that only node without children will be selectable. If choose ``SelectionMethod/nodes`` value (``MultiSelectionMethod/independent`` for ``TreeMultiPicker``), all nodes (include *folders*) will be selectable. For cascading selection of option children in ``TreeMultiPicker`` you need to use ``MultiSelectionMethod/cascading`` value. Create multi picker with cascading selection method for example:

```swift
TreeMultiPicker("Location", data: locations, children: \.children, selection: $multiSelection, selectionMethod: .cascading) { location in
    Text(location.title)
}
```

![TreeMultiPicker with cascading selection method on iOS example](iOS-3.gif)
