import SwiftUI

struct DiagnosticsView: View {
    let messages: [String]

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: UIConstants.Padding.medium) {
                ForEach(messages.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: UIConstants.Padding.medium) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)

                        Text(messages[index])
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}
