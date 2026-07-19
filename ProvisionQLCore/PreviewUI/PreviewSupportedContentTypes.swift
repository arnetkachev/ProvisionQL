import UniformTypeIdentifiers

public enum PreviewSupportedContentTypes {
    public static let ipa = UTType(filenameExtension: "ipa")!
    public static let trollStoreIPA = UTType(importedAs: "com.opa334.trollstore.tipa")
    public static let dynamicTrollStoreIPA = UTType("dyn.ah62d4rv4ge81k4puqe")!
    public static let xcodeArchive = UTType(filenameExtension: "xcarchive", conformingTo: .package)!
    public static let appExtension = UTType.applicationExtension
    public static let mobileProvision = UTType(filenameExtension: "mobileprovision")!
    public static let legacyMobileProvision = UTType(importedAs: "com.apple.iphone.mobileprovision")
    public static let provisionProfile = UTType(filenameExtension: "provisionprofile")!

    public static let all: [UTType] = [
        ipa,
        trollStoreIPA,
        xcodeArchive,
        appExtension,
        mobileProvision,
        legacyMobileProvision,
        provisionProfile,
    ]

    static func isAppArchive(_ contentType: UTType) -> Bool {
        switch contentType.identifier {
        case ipa.identifier,
             trollStoreIPA.identifier,
             dynamicTrollStoreIPA.identifier,
             xcodeArchive.identifier,
             appExtension.identifier:
            true
        default:
            false
        }
    }

    static func isProvisioningProfile(_ contentType: UTType) -> Bool {
        switch contentType.identifier {
        case mobileProvision.identifier,
             legacyMobileProvision.identifier,
             provisionProfile.identifier:
            true
        default:
            false
        }
    }
}
