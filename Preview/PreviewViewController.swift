//
//  PreviewViewController.swift
//  Preview
//
//  Created by Evgeny Aleksandrov

import Cocoa
import PreviewUI
import Quartz
import SwiftUI

class PreviewViewController: NSViewController, QLPreviewingController {
    private let model = PreviewModel()

    override func loadView() {
        let rootView = PreviewRootView(model: model)
            .environment(\.allowsExternalLinks, false)
        let hostingController = NSHostingController(rootView: rootView)
        hostingController.sizingOptions = []

        view = hostingController.view
        addChild(hostingController)

        preferredContentSize = NSSize(width: 800, height: 600)
    }

    func preparePreviewOfFile(at url: URL) async throws {
        await model.previewRequested(for: url)
    }
}
