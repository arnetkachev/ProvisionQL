import Foundation
@testable import PreviewUI
import ProvisionQLCore
import Testing

@Suite("Preview UI Tests")
struct PreviewUITests {
    @Test("Unsupported files are rejected before profile parsing")
    @MainActor
    func unsupportedFileType() async throws {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "\(UUID()).txt")
        try Data("not a provisioning profile".utf8).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let model = PreviewModel()
        await model.previewRequested(for: url)

        guard case let .failed(failure, _) = model.content else {
            Issue.record("Expected unsupported file to fail")
            return
        }

        #expect(failure.message == ParsingError.unsupportedFileType.localizedDescription)
    }
}
