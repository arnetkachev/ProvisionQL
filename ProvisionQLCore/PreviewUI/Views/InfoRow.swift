import SwiftUI

struct InfoRow: View {
    let label: String
    let value: String
    let link: URL?
    @Environment(\.allowsExternalLinks) private var allowsExternalLinks

    init(label: String, value: String, link: URL? = nil) {
        self.label = label
        self.value = value
        self.link = link
    }

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .fontWeight(.medium)
                .frame(minWidth: UIConstants.Size.minLabelWidth, alignment: .leading)
                .foregroundColor(.secondary)

            HStack(spacing: UIConstants.Padding.small) {
                Text(value)
                    .textSelection(.enabled)

                if let link, allowsExternalLinks {
                    Link(destination: link) {
                        Image(systemName: "arrow.up.right.square")
                    }
                    .accessibilityLabel("Open in App Store")
                    .help("Open in App Store")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
