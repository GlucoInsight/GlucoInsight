//
//  GlucoseData.swift
//  GlucoInsight
//
//  Created by YI HE on 2024/7/18.
//

import Foundation

struct GlucoseReading: Identifiable {
    let id = UUID()
    let time: Date
    let value: Double
}

struct GlucoseResponse: Codable {
    let success: Bool
    let data: [GlucoseData]
}

struct GlucoseData: Codable {
    let id: Int
    let timestamp: String
    let glucoValue: Double
}
