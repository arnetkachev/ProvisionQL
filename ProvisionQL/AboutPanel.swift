import AppKit

enum AboutPanel {
    static let repositoryURL = URL(string: "https://github.com/ealeksandrov/ProvisionQL")!
    static let privacyPolicyURL = URL(string: "https://github.com/ealeksandrov/ProvisionQL/blob/main/PRIVACY.md")!

    @MainActor
    static func show() {
        NSApp.orderFrontStandardAboutPanel(options: [
            .credits: credits
        ])
    }

    private static var credits: NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let credits = NSMutableAttributedString()
        for (title, url) in [("GitHub", repositoryURL), ("Privacy Policy", privacyPolicyURL)] {
            if credits.length > 0 {
                credits.append(NSAttributedString(
                    string: "  ·  ",
                    attributes: [
                        .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
                        .foregroundColor: NSColor.secondaryLabelColor,
                        .paragraphStyle: paragraphStyle,
                    ]
                ))
            }
            credits.append(NSAttributedString(
                string: title,
                attributes: [
                    .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
                    .foregroundColor: NSColor.linkColor,
                    .link: url,
                    .paragraphStyle: paragraphStyle,
                ]
            ))
        }
        return credits
    }
}
