//
//  APIClient.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import Foundation

final class APIClient {
    private lazy var baseURL: URL = {
        return URL(string: "https://api.unsplash.com/")!
    }()
    private(set) lazy var session: URLSession = {
        return URLSession.shared
    }()
    
    // MARK: - Fetching Photos
    func fetchPhotos(from page: Int, completion: @escaping (Result<APIResponse, DataResponseError>) -> Void) {
        let urlRequest = URLRequest(url: baseURL.appendingPathComponent(APIRequest.photosPath))
        guard let clientID = APIRequest.clientID else {
            completion(Result.failure(.noAccessKey))
            return
        }
        let parameters = ["per_page": "\(APIRequest.photoPerPage)", "page": "\(page)"]
        var encodedURLRequest = urlRequest.encode(with: parameters)
        encodedURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        encodedURLRequest.setValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
        session.dataTask(with: encodedURLRequest, completionHandler: { data, response, _ in
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.hasSuccessStatusCode,
                let data = data
                else {
                    completion(Result.failure(.network))
                    return
            }
            guard let decodedResponse = try? JSONDecoder().decode(Array<Photo>.self, from: data),
                let xTotal = httpResponse.allHeaderFields["x-total"] as? String,
                let totalPhotos = Int(xTotal)
                else {
                completion(Result.failure(.decoding))
                return
            }

            let apiResponse = APIResponse(photos: decodedResponse, totalPhotos: totalPhotos, page: page, photosPerPage: APIRequest.photoPerPage)
            completion(Result.success(apiResponse))
        }).resume()
    }
}
