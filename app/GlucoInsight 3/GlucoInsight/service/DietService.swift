//
//  DietService.swift
//  GlucoInsight
//
//  Created by Rong Han & Sichao He on 2024/7/18.
//

import Foundation

class DietService {
    private let url1 = URL(string: "http://glucoinsight.simolark.com:8080/diet?user_id=1")!
    private let url2 = URL(string: "http://glucoinsight.simolark.com:8080/diet?user_id=2")!
    
    func fetchDietData(completion: @escaping ([Diet]?) -> Void) {
        let task = URLSession.shared.dataTask(with: url1) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let dietResponse = try decoder.decode(DietResponse.self, from: data)
                let sortedDiets = dietResponse.data.sorted { diet1, diet2 in
                    guard let date1 = Diet.dateFormatter.date(from: diet1.startTime),
                          let date2 = Diet.dateFormatter.date(from: diet2.startTime) else {
                        return false
                    }
                    return date1 > date2
                }
                completion(sortedDiets)
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }

    func fetchDietData2(completion: @escaping ([Diet]?) -> Void) {
        let task = URLSession.shared.dataTask(with: url2) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let dietResponse = try decoder.decode(DietResponse.self, from: data)
                let sortedDiets = dietResponse.data.sorted { diet1, diet2 in
                    guard let date1 = Diet.dateFormatter.date(from: diet1.startTime),
                          let date2 = Diet.dateFormatter.date(from: diet2.startTime) else {
                        return false
                    }
                    return date1 > date2
                }
                completion(sortedDiets)
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}

