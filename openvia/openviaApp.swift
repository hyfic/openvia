import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var settingsWindow: NSWindow?
    var openedViaURL = false
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleURLEvent(_:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // If it was launched manually (not via URL), show the settings
        if !openedViaURL {
            showSettings()
        }
    }
    
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        openedViaURL = true
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
           let url = URL(string: urlString) {
            Router.shared.route(url: url)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Called when user clicks the app icon in Dock or Finder while it's already running
        showSettings()
        return true
    }
    
    func showSettings() {
        if settingsWindow == nil {
            let contentView = ContentView()
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 520, height: 450),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            window.center()
            window.title = "OpenVia Settings"
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: contentView)
            window.delegate = self
            settingsWindow = window
        }
        
        // Temporarily act as a regular app to show the dock icon and allow window interaction
        NSApp.setActivationPolicy(.regular)
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func windowWillClose(_ notification: Notification) {
        // Revert to background daemon behavior when the settings window is closed
        NSApp.setActivationPolicy(.accessory)
    }
}

@main
struct openviaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // We use an empty Settings scene so SwiftUI doesn't complain about a missing scene,
        // but we manage our actual window manually in AppDelegate.
        Settings {
            EmptyView()
        }
    }
}
