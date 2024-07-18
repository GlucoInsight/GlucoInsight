//
//  UserInfoService.swift
//  GlucoInsight
//
//  Created by YI HE on 2024/7/18.
//

import Foundation

class UserInfoService {
    private let url = URL(string: "http://glucoinsight.simolark.com:8080/information?user_id=1")!
    
    func fetchLatestUserInfo(completion: @escaping (UserDetail?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let userInfoResponse = try decoder.decode(UserInfoResponse.self, from: data)
                
                if let userData = userInfoResponse.data.first {
                    let userInfo = UserInfo(
                        name: userData.user.name,
                        age: String(userData.user.age),
                        height: String(format: "%.1f", userData.height),
                        weight: String(format: "%.1f", userData.weight)
                    )
                    let userDetail = UserDetail(userInfo: userInfo, glucoType: userData.glucoType)
                    completion(userDetail)
                } else {
                    completion(nil)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
