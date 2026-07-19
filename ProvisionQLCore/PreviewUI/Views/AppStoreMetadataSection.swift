import ProvisionQLCore
import SwiftUI

struct AppStoreMetadataSection: View {
    let metadata: AppStoreMetadata
    let appName: String

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: UIConstants.Padding.medium) {
                if let appStoreID = metadata.appStoreID {
                    InfoRow(
                        label: "App Store ID",
                        value: appStoreID,
                        link: metadata.appStoreURL
                    )
                }

                if let name = metadata.name, name != appName {
                    InfoRow(label: "Store Name", value: name)
                }

                if let developer = metadata.developer {
                    InfoRow(label: "Developer", value: developer)
                }

                if let releaseDate = metadata.releaseDate {
                    InfoRow(
                        label: "Released",
                        value: releaseDate.formatted(date: .long, time: .omitted)
                    )
                }

                if let appleID = metadata.appleID {
                    InfoRow(label: "Apple ID", value: appleID)
                }
            }
        }
    }
}

extension AppStoreMetadata {
    var appStoreURL: URL? {
        guard let appStoreID,
              !appStoreID.isEmpty,
              appStoreID.allSatisfy({ $0.isASCII && $0.isNumber })
        else {
            return nil
        }

        return URL(string: "https://apps.apple.com/app/id\(appStoreID)")
    }
}
