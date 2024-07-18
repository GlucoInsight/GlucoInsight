//
//  GlucoseService.swift
//  GlucoInsight
//
//  Created by YI HE on 2024/7/18.
//

import Foundation

class GlucoseService {
    private let url = URL(string: "http://glucoinsight.simolark.com:8080/gluco?user_id=1")!
    
    func fetchGlucoseData(completion: @escaping ([GlucoseReading]?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                let response = try decoder.decode(GlucoseResponse.self, from: data)
                if response.success {
                    let readings = response.data.map { GlucoseReading(time: ISO8601DateFormatter().date(from: $0.timestamp) ?? Date(), value: $0.glucoValue / 10) }
                    completion(readings)
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
    
    func fetchLatest10GlucoseValues(completion: @escaping ([Double]?) -> Void) {
        fetchGlucoseData { readings in
            if let readings = readings {
                let latest10Values = readings.prefix(10).map { $0.value }
                completion(latest10Values)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchLatestGlucoseReading(completion: @escaping (Double?) -> Void) {
            fetchGlucoseData { readings in
                if let latestReading = readings?.first {
                    completion(latestReading.value)
                } else {
                    completion(nil)
                }
            }
        }
}

