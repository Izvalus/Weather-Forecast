//
//  NetworkClient.swift
//  Weather_Forecast
//
//  Created by Роман Мироненко on 22.10.2020.
//  Copyright © 2020 Роман Мироненко. All rights reserved.
//

import Foundation

import Alamofire

final class NetworkClient {
    
    enum Error: Swift.Error{
        case http(Swift.Error)
    }
    
    enum ClientAPI {
        
        case openWeatherMap
        case rapidAPI
        
        var baseURL: String {
            switch self {
            case .openWeatherMap:
                return "https://api.openweathermap.org/data/2.5/"
            case .rapidAPI:
                return "https://rapidapi.p.rapidapi.com/forecast/"
            }
        }
        
        var APIToken: [String: String] {
            if case .openWeatherMap = self {
                return ["APPID": "df64baf7c7acf36b9f2d43d586d42506"]
            }
            return [:]
        }
        
        var autentificationHeaders: [String: String] {
            if case .rapidAPI = self {
                return ["x-rapidapi-host": "community-open-weather-map.p.rapidapi.com",
                        "x-rapidapi-key": "ae52450161mshf10303c71c26dc7p107729jsn489ff100975b"]
            }
            return [:]
        }
        
        
    }
    
    private let session = Alamofire.SessionManager()
    
    private lazy var decoder: JSONDecoder = {
        var decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func request<ResponseModel: Decodable>(
        client: ClientAPI,
        endpoint: String,
        method: HTTPMethod = .get,
        params: [String: Any],
        respons: @escaping ((Result<ResponseModel, Error>) -> Void)
        ) {
        let fullURL = "\(client.baseURL)\(endpoint)"
        var newParams = params
        client.APIToken.forEach { (arg0) in
            let (key, value) = arg0
            newParams[key] = value
        }
        let request = session.request(
            fullURL,
            method: method,
            parameters: newParams,
            encoding: parameterEncoding(method: method),
            headers: client.autentificationHeaders
        )
        request.validate().responseData { (dataResponse: DataResponse<Data>) in
            do {
                let result = try dataResponse.result.get()
                let model = try self.decoder.decode(ResponseModel.self, from: result)
                respons(.success(model))
            } catch {
                respons(Result.failure(Error.http(error)))
            }
        }
    }
    
    private func parameterEncoding(method: HTTPMethod) -> ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding()
        default:
            return JSONEncoding()
        }
    }
    
}

extension Alamofire.Result {
    func get() throws -> Value {
        if let value = self.value {
            return value
        }
        throw error!
    }
}
