//
//  ArchiveUtilities.swift
//  ProvisionQLCore
//
//  Created by Evgeny Aleksandrov

import Foundation
import ZIPFoundation

/// Utilities for working with ZIP archives
enum ArchiveUtilities {
    // MARK: - Archive Entry Extraction

    /// Extracts data from a specific file in the archive if present.
    /// - Parameters:
    ///   - archive: The ZIP archive
    ///   - path: The path to the file within the archive
    ///   - caseInsensitive: Whether to fall back to a case-insensitive entry search
    /// - Returns: The extracted data if found, nil otherwise
    /// - Throws: Error if extraction fails
    static func extractFileIfPresent(
        from archive: Archive,
        path: String,
        caseInsensitive: Bool = false
    ) throws -> Data? {
        guard let entry = findEntry(in: archive, path: path, caseInsensitive: caseInsensitive) else {
            return nil
        }

        var data = Data()
        _ = try archive.extract(entry) { chunk in
            data.append(chunk)
        }
        return data
    }

    /// Extracts a specific file to disk if present.
    /// - Parameters:
    ///   - archive: The ZIP archive
    ///   - path: The path to the file within the archive
    ///   - destinationURL: The destination file URL
    ///   - caseInsensitive: Whether to fall back to a case-insensitive entry search
    /// - Returns: `true` if the file was found and extracted, otherwise `false`
    /// - Throws: Error if extraction fails
    static func extractFileIfPresent(
        from archive: Archive,
        path: String,
        to destinationURL: URL,
        caseInsensitive: Bool = false
    ) throws -> Bool {
        guard let entry = findEntry(in: archive, path: path, caseInsensitive: caseInsensitive) else {
            return false
        }

        try FileManager.default.createDirectory(
            at: destinationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        _ = try archive.extract(entry, to: destinationURL)
        return true
    }

    private static func findEntry(in archive: Archive, path: String, caseInsensitive: Bool) -> Entry? {
        if let entry = archive[path] {
            return entry
        }

        guard caseInsensitive else {
            return nil
        }

        let lowercasedPath = path.lowercased()
        return archive.first { $0.path.lowercased() == lowercasedPath }
    }

    // MARK: - App Bundle Path Finding

    /// Finds the top-level `Payload/*.app/` bundle path in an IPA archive.
    /// Works whether or not the archive contains directory entries, and ignores
    /// nested bundles like `Payload/App.app/Watch/WatchApp.app/`.
    /// - Parameter archive: The ZIP archive
    /// - Returns: The app bundle path including trailing slash
    /// - Throws: ParsingError if no app bundle is found
    static func findAppBundlePath(in archive: Archive) throws -> String {
        for entry in archive {
            let components = entry.path.components(separatedBy: "/")
            guard components.count >= 2,
                  components[0] == "Payload",
                  components[1].hasSuffix(".app")
            else {
                continue
            }

            return "Payload/\(components[1])/"
        }

        throw ParsingError.invalidAppBundle
    }
}
