//
//  APIService.swift
//  PodcastsApp
//
//  Created by Алексей Пархоменко on 14/07/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import Foundation
import Alamofire

class APIService {
    
    fileprivate var timer: Timer?
    static let shared = APIService()
    
    // @escaping - рассказывают зачем он нужен в 6 уроке
    func fetchPodcasts(searchText: String, completion: @escaping (SearchResults?) -> Void) {
    
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            
            let url = "https://itunes.apple.com/search"
            let parameters = ["term": searchText]
            
            // encoding - меняет пробелы на амперсанты
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
                if let err = dataResponse.error {
                    print("Failed to contact yahoo", err)
                    completion(nil)
                    return
                }
                
                guard let data = dataResponse.data else { return }
                
                do {
                    let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                    completion(searchResult)
                } catch let decodeErr {
                    print("Failed to decode:", decodeErr)
                    completion(nil)
                }
            }
        }) // timer
    }
}
