# TreePicker

A pack of SwiftUI tree pickers that provide selecting options from hierarchical data. Pickers work on iOS, iPadOS and visionOS. Library hasn't third-party dependencies.

![TreeMultiPicker example](Sources/TreePicker/TreePicker.docc/Resources/iOS-1.png)

[![Latest release](https://img.shields.io/github/v/release/borisovodov/TreePicker)](https://github.com/borisovodov/TreePicker/releases)
[![Build and test status](https://github.com/borisovodov/TreePicker/actions/workflows/workflow.yml/badge.svg)](https://github.com/borisovodov/TreePicker/actions/workflows/workflow.yml)
[![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fborisovodov%2FTreePicker%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/borisovodov/TreePicker)
[![Available platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fborisovodov%2FTreePicker%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/borisovodov/TreePicker)

## Features

`TreePicker` package has several tree pickers for different selection value: exactly one selected value, optional value and set of values. Use `TreeSinglePicker`, `TreeOptionalPicker` and `TreeMultiPicker` respectively.

Work with hierarchical data, it's children and selection is similar to SwiftUI hierarchical `List`. Additionaly you can specify selection method. Next methods available:
* Only leaves (nodes without children) are selectable.
* All nodes (include *folders*) are selectable.
* All nodes are selectable and selecting a node automatically selects all its child nodes. This method is available for `TreeMultiPicker` only.

## Usage

See the [documentation](https://swiftpackageindex.com/borisovodov/TreePicker/main/documentation/treepicker).
