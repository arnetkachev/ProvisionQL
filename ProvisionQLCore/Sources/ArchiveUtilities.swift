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

    /// Extracts data from a specific file in the archive
    /// - Parameters:
    ///   - archive: The ZIP archive
    ///   - path: The path to the file within the archive
    /// - Returns: The extracted data
    /// - Throws: ParsingError if the file cannot be found or extracted
    static func extractFile(from archive: Archive, path: String) throws -> Data {
        guard let entry = archive[path] else {
            throw ParsingError.archiveExtractionFailed
        }

        return try extractData(from: entry, in: archive)
    }

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
        if let entry = archive[path] {
            return try extractData(from: entry, in: archive)
        }

        guard caseInsensitive else {
            return nil
        }

        for entry in archive {
            if entry.path.lowercased() == path.lowercased() {
                return try extractData(from: entry, in: archive)
            }
        }

        return nil
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
        if let entry = archive[path] {
            try extract(entry, from: archive, to: destinationURL)
            return true
        }

        guard caseInsensitive else {
            return false
        }

        for entry in archive {
            if entry.path.lowercased() == path.lowercased() {
                try extract(entry, from: archive, to: destinationURL)
                return true
            }
        }

        return false
    }

    /// Extracts data from an archive entry
    /// - Parameters:
    ///   - entry: The archive entry
    ///   - archive: The archive containing the entry
    /// - Returns: The extracted data
    /// - Throws: Error if extraction fails
    private static func extractData(from entry: Entry, in archive: Archive) throws -> Data {
        var data = Data()
        _ = try archive.extract(entry) { chunk in
            data.append(chunk)
        }
        return data
    }

    private static func extract(_ entry: Entry, from archive: Archive, to destinationURL: URL) throws {
        try FileManager.default.createDirectory(
            at: destinationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        _ = try archive.extract(entry, to: destinationURL)
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
