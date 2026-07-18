//
//  ViewModifiers.swift
//  Preview
//
//  Created by Evgeny Aleksandrov

import SwiftUI

extension View {
    func sectionBackground() -> some View {
        padding(.vertical, UIConstants.Padding.standard)
            .padding(.horizontal, UIConstants.Padding.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(UIConstants.CornerRadius.standard)
    }

    func codeText(_ size: Font.TextStyle = .body) -> some View {
        font(.system(size, design: .monospaced))
            .textSelection(.enabled)
    }
}

enum UIConstants {
    enum Padding {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let standard: CGFloat = 12
        static let large: CGFloat = 16
    }

    enum CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 6
        static let standard: CGFloat = 8
        static let large: CGFloat = 12
    }

    enum Size {
        static let iconSize: CGFloat = 64
        static let minLabelWidth: CGFloat = 100
    }

    enum Width {
        static let dateColumn: CGFloat = 150
    }

    enum Window {
        static let minWidth: CGFloat = 600
        static let minHeight: CGFloat = 400
    }

    enum Color {
        static let validGreen = SwiftUI.Color(nsColor: .systemGreen)
    }
}
