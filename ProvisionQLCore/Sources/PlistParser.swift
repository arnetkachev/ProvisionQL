//
//  PlistParser.swift
//  ProvisionQLCore
//
//  Created by Evgeny Aleksandrov

import Foundation

/// Utilities for parsing property list files
enum PlistParser {
    // MARK: - Plist Parsing

    /// Parses a property list from data
    /// - Parameter data: The plist data
    /// - Returns: The parsed dictionary
    /// - Throws: ParsingError if the plist is invalid or not a dictionary
    static func parse(data: Data) throws -> [String: Any] {
        let plist = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        )

        guard let dictionary = plist as? [String: Any] else {
            throw ParsingError.missingInfoPlist
        }

        return dictionary
    }

    /// Parses a property list from a file URL
    /// - Parameter url: The URL to the plist file
    /// - Returns: The parsed dictionary
    /// - Throws: Error if file cannot be read or parsed
    static func parse(url: URL) throws -> [String: Any] {
        let data = try Data(contentsOf: url)
        return try parse(data: data)
    }

    static func extractAppStoreMetadata(from plist: [String: Any]) -> AppStoreMetadata? {
        let appStoreID = metadataString(from: plist["itemId"])
        let name = trimmedString(from: plist["itemName"])
        let developer = trimmedString(from: plist["artistName"])
        let releaseDate = metadataDate(from: plist["releaseDate"])
        let appleID = extractAppleID(from: plist)

        guard appStoreID != nil || name != nil || developer != nil || releaseDate != nil || appleID != nil else {
            return nil
        }

        return AppStoreMetadata(
            appStoreID: appStoreID,
            name: name,
            developer: developer,
            releaseDate: releaseDate,
            appleID: appleID
        )
    }

    private static func extractAppleID(from plist: [String: Any]) -> String? {
        let downloadInfo = plist["com.apple.iTunesStore.downloadInfo"] as? [String: Any]
        let accountInfo = downloadInfo?["accountInfo"] as? [String: Any]
        let nestedAppleID = trimmedString(from: accountInfo?["AppleID"])

        return [
            nestedAppleID,
            trimmedString(from: plist["apple-id"]),
            trimmedString(from: plist["appleId"]),
        ].compactMap(\.self).first
    }

    private static func metadataString(from value: Any?) -> String? {
        if let string = trimmedString(from: value) {
            return string
        }

        return (value as? NSNumber)?.stringValue
    }

    private static func trimmedString(from value: Any?) -> String? {
        guard let string = value as? String else {
            return nil
        }

        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func metadataDate(from value: Any?) -> Date? {
        if let date = value as? Date {
            return date
        }

        guard let string = trimmedString(from: value) else {
            return nil
        }

        return ISO8601DateFormatter().date(from: string)
    }

    // MARK: - App Info Extraction

    /// Extracts app information from an Info.plist dictionary
    /// - Parameter plist: The parsed Info.plist dictionary
    /// - Returns: The app info structure
    static func extractAppInfo(from plist: [String: Any]) -> AppInfo {
        let bundleIdentifier = plist["CFBundleIdentifier"] as? String ?? "Unknown"
        let name = extractAppName(from: plist)
        // Fall back between the real version fields instead of inventing values.
        let shortVersion = plist["CFBundleShortVersionString"] as? String
        let bundleVersion = plist["CFBundleVersion"] as? String
        let version = shortVersion ?? bundleVersion ?? "Unknown"
        let buildNumber = bundleVersion ?? version
        let deviceFamily = extractDeviceFamily(from: plist)
        let minimumOSVersion = extractMinimumOSVersion(from: plist)
        let sdkVersion = extractSDKVersion(from: plist)
        let extensionPointIdentifier = plist["NSExtensionPointIdentifier"] as? String

        return AppInfo(
            name: name,
            bundleIdentifier: bundleIdentifier,
            version: version,
            buildNumber: buildNumber,
            embeddedProvisioningProfile: nil,
            entitlements: [:],
            deviceFamily: deviceFamily,
            minimumOSVersion: minimumOSVersion,
            sdkVersion: sdkVersion,
            extensionPointIdentifier: extensionPointIdentifier
        )
    }

    /// Extracts the app name from plist, trying multiple possible keys
    private static func extractAppName(from plist: [String: Any]) -> String {
        // Try different name keys in order of preference
        if let displayName = plist["CFBundleDisplayName"] as? String {
            return displayName
        }
        if let bundleName = plist["CFBundleName"] as? String {
            return bundleName
        }
        if let executableName = plist["CFBundleExecutable"] as? String {
            return executableName
        }
        return "Unknown"
    }

    /// Extracts device family information
    private static func extractDeviceFamily(from plist: [String: Any]) -> [String] {
        var devices: [String] = []

        if let deviceFamily = plist["UIDeviceFamily"] as? [Int] {
            for family in deviceFamily {
                switch family {
                case 1: devices.append("iPhone")
                case 2: devices.append("iPad")
                case 3: devices.append("Apple TV")
                case 4: devices.append("Apple Watch")
                case 6: devices.append("Mac (Designed for iPad)")
                case 7: devices.append("Apple Vision")
                default: devices.append("Unknown Device (\(family))")
                }
            }
        }

        return devices
    }

    /// Extracts minimum OS version
    private static func extractMinimumOSVersion(from plist: [String: Any]) -> String? {
        // Try iOS first (most common)
        if let version = plist["MinimumOSVersion"] as? String {
            return version
        }
        // Try other platform-specific keys
        if let version = plist["LSMinimumSystemVersion"] as? String {
            return version
        }
        return nil
    }

    /// Extracts SDK version
    private static func extractSDKVersion(from plist: [String: Any]) -> String? {
        // Try different SDK keys
        if let sdkName = plist["DTSDKName"] as? String {
            return sdkName
        }
        if let sdkBuild = plist["DTSDKBuild"] as? String {
            return sdkBuild
        }
        return nil
    }

    /// Extracts the executable name from plist
    static func extractExecutableName(from plist: [String: Any]) -> String? {
        plist["CFBundleExecutable"] as? String
    }
}
