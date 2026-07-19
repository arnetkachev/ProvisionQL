//
//  ContentView.swift
//  ProvisionQL
//
//  Created by Evgeny Aleksandrov

import AppKit
import PreviewUI
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Binding var fileURL: URL?
    @State private var model = HostAppModel()
    @State private var windowID = UUID()
    @Environment(\.openWindow) private var openWindow
    @AppStorage("extensionHintDismissed") private var extensionHintDismissed = false
    @State private var isDropTargeted = false

    var body: some View {
        VStack(spacing: 0) {
            if !extensionHintDismissed {
                ExtensionHintBanner(
                    openSettings: openExtensionSettings,
                    dismiss: dismissExtensionHint
                )
            }

            ZStack {
                if model.hasOpenedFile {
                    PreviewRootView(model: model.previewModel)
                } else {
                    EmptyStateView(isTargeted: isDropTargeted, openFile: openFile)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                if isDropTargeted {
                    Color.accentColor
                        .opacity(0.08)
                        .ignoresSafeArea()
                }
            }
            .onDrop(
                of: [UTType.fileURL.identifier],
                isTargeted: $isDropTargeted,
                perform: handleDrop
            )
        }
        .frame(minWidth: 720, minHeight: 520)
        // Steers open events toward the window already showing that file (or
        // an empty one) instead of spawning an extra scene; delivery itself
        // happens through FileOpenRouter.
        .handlesExternalEvents(
            preferring: fileURL.map { [$0.absoluteString] } ?? [],
            allowing: fileURL == nil ? ["*"] : []
        )
        .onAppear(perform: registerAndDrainFileOpens)
        .onChange(of: fileURL) {
            updateEmptyWindowClaim()
        }
        .onDisappear {
            FileOpenRouter.shared.setEmptyWindowClaim(id: windowID, claim: nil)
        }
        .task(id: fileURL) {
            if let fileURL {
                await model.previewRequested(for: fileURL)
            }
        }
        .navigationTitle(model.windowTitle)
        .toolbar {
            ToolbarItemGroup {
                Button(action: openFile) {
                    Label("Open File", systemImage: "doc.badge.plus")
                }
                .help("Open a supported file")

                Button(action: openExtensionSettings) {
                    Label("Extensions", systemImage: "puzzlepiece.extension")
                }
                .help("Open Extensions settings")
            }
        }
    }

    private func dismissExtensionHint() {
        extensionHintDismissed = true
    }

    private func registerAndDrainFileOpens() {
        let router = FileOpenRouter.shared
        router.openWindow = openWindow
        updateEmptyWindowClaim()

        var urls = router.takePending()
        guard !urls.isEmpty else {
            return
        }

        if fileURL == nil {
            fileURL = urls.removeFirst()
        }

        for url in urls {
            openWindow(value: url)
        }
    }

    private func updateEmptyWindowClaim() {
        if fileURL == nil {
            FileOpenRouter.shared.setEmptyWindowClaim(id: windowID) { fileURL = $0 }
        } else {
            FileOpenRouter.shared.setEmptyWindowClaim(id: windowID, claim: nil)
        }
    }

    private func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = PreviewSupportedContentTypes.all
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        // Packages (.xcarchive, .appex) stay selectable via allowedContentTypes;
        // this only filters out arbitrary plain folders.
        panel.canChooseDirectories = false

        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }

        fileURL = url
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: {
            $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
        }) else {
            return false
        }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            guard let url = Self.fileURL(from: item) else {
                return
            }

            Task { @MainActor in
                fileURL = url
            }
        }

        return true
    }

    private func openExtensionSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") else {
            return
        }

        NSWorkspace.shared.open(url)
    }

    private nonisolated static func fileURL(from item: NSSecureCoding?) -> URL? {
        if let url = item as? URL {
            return url
        }

        if let data = item as? Data {
            return URL(dataRepresentation: data, relativeTo: nil)
        }

        if let string = item as? String {
            if let url = URL(string: string), url.scheme != nil {
                return url
            }

            return URL(fileURLWithPath: NSString(string: string).expandingTildeInPath)
        }

        return nil
    }
}

private struct ExtensionHintBanner: View {
    let openSettings: () -> Void
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "puzzlepiece.extension")
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Quick Look previews may need to be enabled")
                    .font(.headline)
                Text("Open System Settings if Finder previews do not appear.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Open Settings", action: openSettings)

            Button(action: dismiss) {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Dismiss")
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

private struct EmptyStateView: View {
    let isTargeted: Bool
    let openFile: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: isTargeted ? "tray.and.arrow.down.fill" : "doc.viewfinder")
                .font(.system(size: 48))
                .foregroundStyle(isTargeted ? Color.accentColor : Color.secondary)
                .frame(width: 72, height: 72)

            VStack(spacing: 6) {
                Text("Drop a supported file")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(".ipa, .tipa, .xcarchive, .appex, .mobileprovision, .provisionprofile")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button("Open File...", action: openFile)
                .controlSize(.large)
        }
        .frame(maxWidth: 520, minHeight: 280)
        .padding(32)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .textBackgroundColor))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color.secondary.opacity(0.35),
                    style: StrokeStyle(lineWidth: isTargeted ? 2 : 1, dash: [8, 6])
                )
        }
    }
}

#Preview {
    ContentView(fileURL: .constant(nil))
}
