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
                
                self.labelChevron
            }
        }
        .background(ScreenPositionReader(screenRect: $buttonFrame))
        .onAppear {
            self.panel = MenuPanel(isPresented: $isMenuPresented, contentRect: self.panelFrame) {
                self.menu()
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
            } else {
                self.panel?.close()
            }
        }
        .onChange(of: self.buttonFrame) { _, _ in
            self.panel?.setFrame(self.panelFrame, display: true)
        }
    }
    
    private var labelChevron: some View {
        Image(systemName: "chevron.down.square.fill")
            .clipShape(.capsule)
            .symbolRenderingMode(.multicolor)
            .foregroundStyle(Color.accentColor.gradient)
            .font(.title2)
            .fontWeight(.bold)
            .padding(.trailing, -6)
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
    
    init(isPresented: Binding<Bool>, contentRect: CGRect, @ViewBuilder content: @escaping () -> Content) {
        self._isPresented = isPresented
        
        super.init(contentRect: contentRect, styleMask: [.borderless, .fullSizeContentView, .utilityWindow, .nonactivatingPanel], backing: .buffered, defer: false)
        
        isFloatingPanel = true
        level = .floating
        
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        
        hidesOnDeactivate = true
        
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        
        contentView = NSHostingView(rootView: content())
    }
    
    override func resignMain() {
        super.resignMain()
        close()
    }
    
    override func close() {
        super.close()
        self.isPresented = false
    }
     
    override var canBecomeMain: Bool {
        return true
    }
}

@MainActor struct ScreenPositionReader: NSViewRepresentable {
    @Binding var screenRect: CGRect
    
    func makeNSView(context: Context) -> NSView {
        let view = PositionTrackingNSView()
        view.onPositionUpdate = { [weak view] in
            guard let nsView = view else { return }
            updateScreenRect(nsView: nsView)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        self.updateScreenRect(nsView: nsView)
    }
    
    private func updateScreenRect(nsView: NSView) {
        guard let window = nsView.window else { return }
        
        // Convert view bounds to screen coordinates
        let viewFrameInWindow = nsView.convert(nsView.bounds, to: nil)
        let screenFrame = window.convertToScreen(viewFrameInWindow)
        
        Task { @MainActor in
            self.screenRect = screenFrame
        }
    }
}

@MainActor class PositionTrackingNSView: NSView {
    var onPositionUpdate: (() -> Void)? = nil
    private var observers: [NSObjectProtocol] = []

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        observers.forEach(NotificationCenter.default.removeObserver)
        observers.removeAll()

        guard let window = window else { return }

        let moveObserver = NotificationCenter.default.addObserver(forName: NSWindow.didMoveNotification, object: window, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.onPositionUpdate?()
            }
        }
        let resizeObserver = NotificationCenter.default.addObserver(forName: NSWindow.didResizeNotification, object: window, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.onPositionUpdate?()
            }
        }
        
        observers.append(moveObserver)
        observers.append(resizeObserver)
    }

    override func layout() {
        super.layout()
        onPositionUpdate?()
    }
    
    deinit {
        MainActor.assumeIsolated {
            observers.forEach(NotificationCenter.default.removeObserver)
        }
    }
}
#endif
