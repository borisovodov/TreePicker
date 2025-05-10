//
//  PullDownButton.swift
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

@MainActor internal struct PullDownButton<SelectionContent: View, MenuContent: View>: View {
    
    @State private var isPresented: Bool = false
    
    @State private var panel: MenuPanel<MenuContent>? = nil
    
    private var menu: () -> MenuContent
    
    private var selection: () -> SelectionContent
    
    @MainActor var body: some View {
        GeometryReader { geometryProxy in
            Button(action: { self.isPresented.toggle() }) {
                HStack(spacing: 0) {
                    self.selection()
                    
                    Spacer()
                    
                    LabelChevron()
                }
            }
            .onAppear {
                // TODO: refactor
                let frame = geometryProxy.frame(in: .global)
                let width = frame.width
                self.panel = MenuPanel(isPresented: $isPresented, contentRect: CGRect(x: frame.minX, y: frame.maxY, width: width, height: 200)) {
                    self.menu()
                }
                self.panel?.center()
                if self.isPresented {
                    panel?.orderFront(nil)
                    panel?.makeKey()
                }
            }
            .onDisappear {
                // TODO: refactor
                self.panel?.close()
                self.panel = nil
            }
            .onChange(of: isPresented) { value in
                // TODO: refactor
                if value {
                    panel?.orderFront(nil)
                    panel?.makeKey()
                } else {
                    self.panel?.close()
                }
            }
        }
        
    }
    
    @MainActor init(@ViewBuilder menu: @escaping () -> MenuContent, @ViewBuilder selection: @escaping () -> SelectionContent) {
        self.menu = menu
        self.selection = selection
    }
}

private class MenuPanel<Content: View>: NSPanel {
    @Binding var isPresented: Bool
    
    // TODO: refactor
    init(isPresented: Binding<Bool>, contentRect: NSRect, backing backingStoreType: NSWindow.BackingStoreType = .buffered, defer flag: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self._isPresented = isPresented
        
        super.init(contentRect: contentRect, styleMask: [.nonactivatingPanel, .titled, .resizable, .closable, .fullSizeContentView], backing: backingStoreType, defer: flag)
        
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
        
        contentView = NSHostingView(rootView: content()
            .ignoresSafeArea()
            .environment(\.floatingPanel, self))
    }
    
    
    override func resignMain() {
        super.resignMain()
        close()
    }
    
    override func close() {
        super.close()
        self.isPresented = false
    }
    
    override var canBecomeKey: Bool {
        return true
    }
     
    override var canBecomeMain: Bool {
        return true
    }
}
#endif
