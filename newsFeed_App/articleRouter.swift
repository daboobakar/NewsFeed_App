//
//  articleRouter.swift
//  pagesuiteTestApplication
//
//  Created by Danyal Aboobakar on 09/03/2017.
//  Copyright © 2017 Danyal Aboobakar. All rights reserved.
//

import Foundation
import Alamofire

enum articleRouter: URLRequestConvertible {
    static let baseURLString = "http://www.independent.co.uk/"
    
    case getArticles()
    
    func asURLRequest() throws -> URLRequest {
        var method: HTTPMethod {
            switch self {
            case .getArticles:
                return .get
                
            }
        }
        let url: URL = {
            let relativePath: String
            switch self {
            case .getArticles():
                relativePath = "api/v1/11831/json"
            }
            
            var url = URL(string: articleRouter.baseURLString)!
            url.appendPathComponent(relativePath)
            return url
        }()
        
        let params: ([String: Any]?) = {
            switch self {
            case .getArticles:
                return nil
            }
        }()
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        let encoding = JSONEncoding.default
        return try encoding.encode(urlRequest, with: params)
    }
    
    
    
}
