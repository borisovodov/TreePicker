# TreePicker

**WORK IN PROGRESS. PLEASE, DON'T USE THIS PACKAGE.**

A pack of SwiftUI tree pickers that provide selecting options from hierarchical data. Pickers work on macOS, iOS and visionOS. Library hasn't third-party dependencies.

![Lowest supported macOS version](https://img.shields.io/badge/macOS-13+-blue)
![Lowest supported iOS version](https://img.shields.io/badge/iOS-16+-blue)
![Lowest supported visionOS version](https://img.shields.io/badge/visionOS-1+-blue)
[![Code coverage status](https://img.shields.io/codecov/c/github/borisovodov/TreePicker)](https://codecov.io/gh/borisovodov/TreePicker)
[![Latest release](https://img.shields.io/github/v/release/borisovodov/TreePicker)](https://github.com/borisovodov/TreePicker/releases) 

## Features

## Installation

### In Xcode

`.xcproject` → PROJECT → Package Dependencies → + → search "https://github.com/borisovodov/TreePicker" → Add Package

## Usage

Рассказать про data и dataID и возможности data когда Identifable

Рассказать про children

Рассказать про три разных пикера с тремя разными selection. Рассказать по какому принципу производится выделение элементов в зависимости от типа selection

Рассказать про разные методы селекшена в разных типах пикера

Рассказать про rowContent

Рассказать про lable

Рассказать про emptySelectionContent и для каких пикеров он доступен
 

## Limitations and caveats

про отказ от tag модифайера рассказать.
/// Other examples of when the views in a picker's ``ForEach`` need an explicit
/// tag modifier include when you:
/// * Select over the cases of an enumeration that conforms to the
///   <doc://com.apple.documentation/documentation/Swift/Identifiable> protocol
///   by using anything besides `Self` as the `id` parameter type. For example,
///   a string enumeration might use the case's `rawValue` string as the `id`.
///   That identifier type doesn't match the selection type, which is the type
///   of the enumeration itself.
/// * Use an optional value for the `selection` input parameter. For that to
///   work, you need to explicitly cast the tag modifier's input as
///   <doc://com.apple.documentation/documentation/Swift/Optional> to match.
///   For an example of this, see ``View/tag(_:)``.
