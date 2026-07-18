import Foundation
import Observation
import ProvisionQLCore
import UniformTypeIdentifiers

@MainActor
@Observable
public final class PreviewModel {
    var content: PreviewContent = .loading

    /// Guards against overlapping requests in the host app: only the latest
    /// request may publish its result.
    private var requestID = 0

    public init() {}

    public func previewRequested(for url: URL) async {
        requestID += 1
        let currentRequestID = requestID

        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        content = .loading

        let newContent: PreviewContent
        do {
            newContent = try await Self.loadContent(for: url)
        } catch {
            let fileInfo = await Self.fileInfo(for: url)
            newContent = .failed(PreviewFailure(error: error), fileInfo)
        }

        if currentRequestID == requestID {
            content = newContent
        }
    }
}

private extension PreviewModel {
    static func loadContent(for url: URL) async throws -> PreviewContent {
        let contentType = try url.resourceValues(forKeys: [.contentTypeKey]).contentType

        if let contentType, PreviewSupportedContentTypes.isAppArchive(contentType) {
            return try await loadAppArchiveContent(for: url)
        }

        return try await loadProvisioningProfileContent(for: url)
    }

    static func loadAppArchiveContent(for url: URL) async throws -> PreviewContent {
        let (result, fileInfo) = try await Task.detached(priority: .userInitiated) {
            let result = try AppArchiveParser.parseWithResources(url)
            let fileInfo = FileInfo(fileURL: url)
            return (result, fileInfo)
        }.value

        return .archive(result.appInfo, result.iconSource, fileInfo)
    }

    static func loadProvisioningProfileContent(for url: URL) async throws -> PreviewContent {
        let (info, fileInfo) = try await Task.detached(priority: .userInitiated) {
            let info = try ProvisioningParser.parse(url)
            let fileInfo = FileInfo(fileURL: url)
            return (info, fileInfo)
        }.value

        return .profile(info, fileInfo)
    }

    static func fileInfo(for url: URL) async -> FileInfo {
        await Task.detached(priority: .utility) {
            FileInfo(fileURL: url)
        }.value
    }
}

enum PreviewContent {
    case loading
    case profile(ProvisioningInfo, FileInfo)
    case archive(AppInfo, IconSource?, FileInfo)
    case failed(PreviewFailure, FileInfo)
}
