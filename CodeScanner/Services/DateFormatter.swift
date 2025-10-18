//
//  DateFormatter.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 18.10.2025.
//

import Foundation

extension DateFormatter {

    private static let shortDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    static func dateString(_ date: Date) -> String {
        return shortDateTimeFormatter.string(from: date)
    }
}
