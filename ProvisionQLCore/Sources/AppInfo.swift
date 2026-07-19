//
//  AppInfo.swift
//  Core
//
//  Created by Evgeny Aleksandrov

import Foundation

public struct AppStoreMetadata: Sendable, Codable, Hashable {
    public let appStoreID: String?
    public let name: String?
    public let developer: String?
    public let releaseDate: Date?
    public let appleID: String?

    public init(
        appStoreID: String? = nil,
        name: String? = nil,
        developer: String? = nil,
        releaseDate: Date? = nil,
        appleID: String? = nil
    ) {
        self.appStoreID = appStoreID
        self.name = name
        self.developer = developer
        self.releaseDate = releaseDate
        self.appleID = appleID
    }
}

public struct AppInfo: Sendable, Codable, Hashable {
    public let name: String
    public let bundleIdentifier: String
    public let version: String
    public let buildNumber: String
    public let appStoreMetadata: AppStoreMetadata?
    public let embeddedProvisioningProfile: ProvisioningInfo?
    public let entitlements: [String: PlistValue]
    public let deviceFamily: [String]
    public let minimumOSVersion: String?
    public let sdkVersion: String?
    public let extensionPointIdentifier: String?
    public let diagnostics: [AppDiagnostic]

    public init(
        name: String,
        bundleIdentifier: String,
        version: String,
        buildNumber: String,
        appStoreMetadata: AppStoreMetadata? = nil,
        embeddedProvisioningProfile: ProvisioningInfo? = nil,
        entitlements: [String: PlistValue] = [:],
        deviceFamily: [String] = [],
        minimumOSVersion: String? = nil,
        sdkVersion: String? = nil,
        extensionPointIdentifier: String? = nil,
        diagnostics: [AppDiagnostic] = []
    ) {
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.version = version
        self.buildNumber = buildNumber
        self.appStoreMetadata = appStoreMetadata
        self.embeddedProvisioningProfile = embeddedProvisioningProfile
        self.entitlements = entitlements
        self.deviceFamily = deviceFamily
        self.minimumOSVersion = minimumOSVersion
        self.sdkVersion = sdkVersion
        self.extensionPointIdentifier = extensionPointIdentifier
        self.diagnostics = diagnostics
    }
}

public extension AppInfo {
    var displayVersion: String {
        if version != buildNumber {
            "\(version) (\(buildNumber))"
        } else {
            version
        }
    }
}
