//
//  PullDownButton.swift
//  TreePicker
//
//  Created by Boris Ovodov on 09.05.2025.
//

import Foundation
import SwiftUI

#if os(macOS)
@MainActor internal struct PullDownButton<SelectionContent: View, MenuContent: View>: View {
    
    @State private var isMenuPresented: Bool = false
    
    @State private var panel: MenuPanel<MenuContent>? = nil
    
    @State private var buttonFrame: CGRect = .zero
    
    private var menu: () -> MenuContent
    
    private var selection: () -> SelectionContent
    
    @MainActor init(@ViewBuilder menu: @escaping () -> MenuContent, @ViewBuilder selection: @escaping () -> SelectionContent) {
        self.menu = menu
        self.selection = selection
    }
    
    @MainActor var body: some View {
        Button(action: { self.isMenuPresented.toggle() }) {
            HStack(spacing: 0) {
                self.selection()
                
                Spacer()
                
                LabelChevron()
            }
        }
        .background(ScreenPositionReader(screenRect: $buttonFrame))
        .onAppear {
            self.panel = MenuPanel(isPresented: $isMenuPresented, contentRect: self.panelFrame) {
                self.menu()
            }
            if self.isMenuPresented {
                panel?.orderFront(nil)
                panel?.makeKey()
            }
        }
        .onDisappear {
            self.panel?.close()
            self.panel = nil
            self.buttonFrame = .zero
        }
        .onChange(of: self.isMenuPresented) { _, newValue in
            if newValue {
                panel?.orderFront(nil)
                panel?.makeKey()
            } else {
                self.panel?.close()
            }
        }
        .onChange(of: self.buttonFrame) { _, _ in
            self.panel?.setFrame(self.panelFrame, display: true)
        }
    }
    
    private var panelFrame: CGRect {
        let height: CGFloat = 200
        return CGRect(
            x: self.buttonFrame.minX,
            y: self.buttonFrame.minY - height,
            width: self.buttonFrame.size.width,
            height: height
        )
    }
}

@MainActor private class MenuPanel<Content: View>: NSPanel {
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>, contentRect: CGRect, backing backingStoreType: NSWindow.BackingStoreType = .buffered, defer flag: Bool = false, @ViewBuilder content: @escaping () -> Content) {
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

private struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSPanel? = nil
}
extension EnvironmentValues {
  var floatingPanel: NSPanel? {
    get { self[FloatingPanelKey.self] }
    set { self[FloatingPanelKey.self] = newValue }
  }
}

// MARK: - NSViewRepresentable to get screen coordinates

@MainActor struct ScreenPositionReader: NSViewRepresentable {
    @Binding var screenRect: CGRect
    
    func makeNSView(context: Context) -> NSView {
        let view = PositionTrackingNSView()
        view.onPositionUpdate = { updateScreenRect(nsView: view) }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        updateScreenRect(nsView: nsView)
    }
    
    private func updateScreenRect(nsView: NSView) {
        guard let window = nsView.window else { return }
                
        // Convert view bounds to screen coordinates
        let viewFrameInWindow = nsView.convert(nsView.bounds, to: nil)
        let screenFrame = window.convertToScreen(viewFrameInWindow)
        
        DispatchQueue.main.async { self.screenRect = screenFrame }
    }
}

// MARK: - Custom NSView to track layout changes

@MainActor class PositionTrackingNSView: NSView {
    var onPositionUpdate: (() -> Void)?
    private var windowObservers: [NSObjectProtocol] = []
    
    override func layout() {
        super.layout()
        onPositionUpdate?()
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        setupWindowObservers()
    }
    
    deinit {
        // Direct access is now safe since class is @MainActor
//        windowObservers.forEach { NotificationCenter.default.removeObserver($0) }
    }
    
    private func setupWindowObservers() {
        windowObservers.forEach { NotificationCenter.default.removeObserver($0) }
        windowObservers.removeAll()
        
        guard let window = window else { return }
        
        let notifications: [NSNotification.Name] = [
            NSWindow.didMoveNotification,
            NSWindow.didResizeNotification,
            NSWindow.didChangeScreenNotification
        ]
        
        notifications.forEach { name in
            let observer = NotificationCenter.default.addObserver(
                forName: name,
                object: window,
                queue: .main
            ) { [weak self] _ in
                // Explicit main actor execution
                Task { @MainActor in
                    self?.updatePosition()
                }
            }
            windowObservers.append(observer)
        }
    }
    
    private func updatePosition() {
        onPositionUpdate?()
    }
}
#endif
