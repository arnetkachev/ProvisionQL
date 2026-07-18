//
//  ProvisionQLApp.swift
//  ProvisionQL
//
//  Created by Evgeny Aleksandrov

import AppKit
import SwiftUI

@main
struct ProvisionQLApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup(for: URL.self) { $url in
            ContentView(fileURL: url)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About ProvisionQL") {
                    AboutPanel.show()
                }
            }
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_: NSApplication, open urls: [URL]) {
        FileOpenRequests.shared.add(urls)
    }
}

/// Finder open events arrive on the app delegate, which has no access to the
/// SwiftUI openWindow action. Requests are queued here and drained take-once
/// by the first window that reacts, so each file opens exactly once.
@MainActor
final class FileOpenRequests {
    static let shared = FileOpenRequests()
    static let notification = Notification.Name("ProvisionQLFileOpenRequests")

    private var pendingURLs: [URL] = []

    func add(_ urls: [URL]) {
        pendingURLs.append(contentsOf: urls)
        NotificationCenter.default.post(name: Self.notification, object: nil)
    }

    func take() -> [URL] {
        defer { pendingURLs.removeAll() }
        return pendingURLs
    }
}
