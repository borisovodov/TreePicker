# ``TreePicker``

SwiftUI tree picker for selecting options from hierarchical data.

## Overview

A pack of SwiftUI tree pickers that provide selecting options from hierarchical data. Pickers work on iOS, iPadOS and visionOS. Library hasn't third-party dependencies.

``TreePicker`` package has several tree pickers for different selection value: exactly one selected value, optional value and set of values. Use ``TreeSinglePicker``, ``TreeOptionalPicker`` and ``TreeMultiPicker`` respectively.

Work with hierarchical data, it's children and selection is similar to SwiftUI hierarchical `List`. Additionaly you can specify selection method. Next methods available:
* Only leaves (nodes without children) are selectable.
* All nodes (include *folders*) are selectable.
* All nodes are selectable and selecting a node automatically selects all its child nodes. This method is available for ``TreeMultiPicker`` only.

![TreeMultiPicker example](iOS-1.png)
