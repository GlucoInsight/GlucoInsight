//
//  UserInfo.swift
//  GlucoInsight
//
//  Created by YI HE on 2024/7/18.
//

import Foundation

struct UserInfo: Codable {
    let name: String
    var age: String
    var height: String
    var weight: String
}

struct UserInfoResponse: Codable {
    let success: Bool
    let message: String?
    let data: [UserData]
    let errors: [String]
    let devMessages: [String]
}

struct UserData: Codable {
    let id: Int
    let user: User
    let timestamp: String
    let heartRate: Int
    let sao2: Int
    let height: Double
    let weight: Double
    let pressure: Double
    let glucoType: Int
}

struct User: Codable {
    let id: Int
    let openId: String?
    let name: String
    let age: Int
    let gender: Int
}

struct UserDetail: Codable {
    let userInfo: UserInfo
    let glucoType: Int
}


