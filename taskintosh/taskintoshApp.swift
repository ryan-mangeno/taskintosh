//
//  taskintoshApp.swift
//  taskintosh
//
//  Created by Ryan Mangeno on 2/19/26.
//


import SwiftUI
import AppKit

@main
struct TaskintoshApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var store = AppStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "text.append", accessibilityDescription: "Treatintosh")
            button.image?.isTemplate = true
            button.action = #selector(togglePopover)
            button.target = self
        }

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 380, height: 520)
        popover.behavior = .transient
        popover.animates = true
        
        let contentView = ContentView().environmentObject(store)
        let hostingController = NSHostingController(rootView: contentView)

        hostingController.view.wantsLayer = true
        let swiftUIColor = Color(hex: "#1E1E1E").opacity(0.85)
        hostingController.view.layer?.backgroundColor = NSColor(swiftUIColor).cgColor

        popover.contentViewController = hostingController
        
        self.popover = popover
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        if let popover, popover.isShown {
            popover.performClose(nil)
        } else {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
