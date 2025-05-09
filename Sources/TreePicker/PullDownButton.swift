//
//  File.swift
//  TreePicker
//
//  Created by Boris Ovodov on 09.05.2025.
//

import Foundation
import SwiftUI

#if os(macOS)
private struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSPanel? = nil
}
extension EnvironmentValues {
  var floatingPanel: NSPanel? {
    get { self[FloatingPanelKey.self] }
    set { self[FloatingPanelKey.self] = newValue }
  }
}

/// An NSPanel subclass that implements floating panel traits.
class FloatingPanel<Content: View>: NSPanel {
    @Binding var isPresented: Bool
    
    init(@ViewBuilder view: @escaping () -> Content,
             contentRect: NSRect,
             backing: NSWindow.BackingStoreType = .buffered,
             defer flag: Bool = false,
             isPresented: Binding<Bool>) {
        /// Initialize the binding variable by assigning the whole value via an underscore
        self._isPresented = isPresented
     
        /// Init the window as usual
        super.init(contentRect: contentRect,
                    styleMask: [.nonactivatingPanel, .titled, .resizable, .closable, .fullSizeContentView],
                    backing: backing,
                    defer: flag)
     
        /// Allow the panel to be on top of other windows
        isFloatingPanel = true
        level = .floating
     
        /// Allow the pannel to be overlaid in a fullscreen space
        collectionBehavior.insert(.fullScreenAuxiliary)
     
        /// Don't show a window title, even if it's set
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
     
        /// Since there is no title bar make the window moveable by dragging on the background
        isMovableByWindowBackground = true
     
        /// Hide when unfocused
        hidesOnDeactivate = true
     
        /// Hide all traffic light buttons
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
     
        /// Sets animations accordingly
        animationBehavior = .utilityWindow
     
        /// Set the content view.
        /// The safe area is ignored because the title bar still interferes with the geometry
        contentView = NSHostingView(rootView: view()
            .ignoresSafeArea()
            .environment(\.floatingPanel, self))
    }
    
    /// Close automatically when out of focus, e.g. outside click
    override func resignMain() {
        super.resignMain()
        close()
    }
     
    /// Close and toggle presentation, so that it matches the current state of the panel
    override func close() {
        super.close()
        isPresented = false
    }
     
    /// `canBecomeKey` and `canBecomeMain` are both required so that text inputs inside the panel can receive focus
    override var canBecomeKey: Bool {
        return true
    }
     
    override var canBecomeMain: Bool {
        return true
    }
}

@MainActor internal struct PullDownButton<SelectionContent: View, MenuContent: View>: View {
    
    @State var isPresented: Bool = false
    
    @State var panel: FloatingPanel<MenuContent>? = nil
    
    private var menu: () -> MenuContent
    
    private var selection: () -> SelectionContent
    
    @MainActor var body: some View {
        Button(action: { self.isPresented.toggle() }) {
            HStack(spacing: 0) {
                self.selection()

                Spacer()

                LabelChevron()
            }
        }
        .onAppear {
            self.panel = FloatingPanel(view: self.menu, contentRect: CGRect(x: 0, y: 0, width: 624, height: 512), isPresented: $isPresented)
            self.panel?.center()
            if self.isPresented {
                panel?.orderFront(nil)
                panel?.makeKey()
            }
        }
        .onDisappear {
            self.panel?.close()
            self.panel = nil
        }
        .onChange(of: isPresented) { value in
            if value {
                panel?.orderFront(nil)
                panel?.makeKey()
            } else {
                self.panel?.close()
            }
        }
    }
    
    @MainActor public init(@ViewBuilder menu: @escaping () -> MenuContent, @ViewBuilder selection: @escaping () -> SelectionContent) {
        self.menu = menu
        self.selection = selection
    }
}
#endif
