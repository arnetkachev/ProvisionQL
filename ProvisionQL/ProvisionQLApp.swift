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
            ContentView(fileURL: $url)
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
        FileOpenRouter.shared.open(urls)
    }
}

/// Finder open events arrive on the app delegate, which has no access to the
/// SwiftUI openWindow action. Windows register the action (and, while empty,
/// a claim to be filled) here; before any window exists (cold launch) URLs
/// wait in the queue and are drained by the first window to appear.
@MainActor
final class FileOpenRouter {
    static let shared = FileOpenRouter()

    var openWindow: OpenWindowAction?
    private var emptyWindowClaims: [UUID: (URL) -> Void] = [:]
    private var pendingURLs: [URL] = []

    func setEmptyWindowClaim(id: UUID, claim: ((URL) -> Void)?) {
        emptyWindowClaims[id] = claim
    }

    func open(_ urls: [URL]) {
        var remaining = urls

        // Fill an existing empty window before spawning new ones.
        if let first = remaining.first, let (id, claim) = emptyWindowClaims.first {
            emptyWindowClaims.removeValue(forKey: id)
            claim(first)
            remaining.removeFirst()
        }

        guard let openWindow else {
            pendingURLs.append(contentsOf: remaining)
            return
        }

        for url in remaining {
            openWindow(value: url)
        }
    }

    func takePending() -> [URL] {
        defer { pendingURLs.removeAll() }
        return pendingURLs
    }
}
