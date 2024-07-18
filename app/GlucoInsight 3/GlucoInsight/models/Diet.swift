//
//  Diet.swift
//  GlucoInsight
//
//  Created by Rong Han & Sichao He on 2024/7/18.
//

import Foundation

struct Diet: Codable, Identifiable {
    let id: Int
    let startTime: String
    let endTime: String
    let carbohydrate: Float
    let fat: Float
    let protein: Float
    
    var startHourMinute: String {
        return convertToHourMinute(from: startTime)
    }
    
    var endHourMinute: String {
        return convertToHourMinute(from: endTime)
    }

    var startDate: String {
        return convertToDate(from: startTime)
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
    static let hourMinuteFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private func convertToHourMinute(from dateString: String) -> String {
        guard let date = Diet.dateFormatter.date(from: dateString) else {
            return ""
        }
        return Diet.hourMinuteFormatter.string(from: date)
    }

    private func convertToDate(from dateString: String) -> String {
        guard let date = Diet.dateFormatter.date(from: dateString) else {
            return ""
        }
        return Diet.dateOnlyFormatter.string(from: date)
    }
}

struct DietResponse: Codable {
    let success: Bool
    let message: String?
    let data: [Diet]
    let errors: [String]
    let devMessages: [String]
}
