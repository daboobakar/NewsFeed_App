//
//  independentAPIManager.swift
//  pagesuiteTestApplication
//
//  Created by Danyal Aboobakar on 09/03/2017.
//  Copyright © 2017 Danyal Aboobakar. All rights reserved.
//

import Foundation
import Alamofire

enum independentAPIManagerError: Error {
    case network(error: Error)
    case apiProvidedError(reason: String)
    case authCouldNot(reason: String)
    case authLost(reason: String)
    case objectSerialization(reason: String)
}

class independentAPIManager {
    
    static let sharedInstance = independentAPIManager()
    
    func clearCache() -> Void {
        let cache = URLCache.shared
        cache.removeAllCachedResponses()
    }
    
    func printArticles() -> Void {
        Alamofire.request(articleRouter.getArticles())
            .responseString { response in
                if let receivedString = response.result.value {
                    print(receivedString)
                }
        }
    }
    
    func fetchArticles(completionHandler: @escaping (Result<[Article]>) -> Void) {
        Alamofire.request(articleRouter.getArticles())
            .responseJSON { response in
                let result = self.articleArrayFromResponse(response: response)
                completionHandler(result)
        }
    }
    
    
    //obtain urlString for image and use it to make GET request & result is turned into image
    func imageFrom(urlString: String, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        let _ = Alamofire.request(urlString)
            .response { dataResponse in
                // use the generic response serializer that returns Data
                guard let data = dataResponse.data else {
                    completionHandler(nil, dataResponse.error)
                    return
                }
                
                let image = UIImage(data: data)
                completionHandler(image, nil)
        }
    }
    
    
    private func articleArrayFromResponse(response: DataResponse<Any>) -> Result<[Article]> {
        guard response.result.error == nil else {
            print(response.result.error!)
            return .failure(independentAPIManagerError.network(error: response.result.error!))
        }
        
        //Error Handling
        
        // make sure we got JSON and it's a dictionary
        guard let jsonTopLevelDictionary = response.result.value as? [String: Any] else {
            print("didn't get JSON in API response")
            return .failure(independentAPIManagerError.objectSerialization(reason: "Did not get JSON dictionary in response"))
        }
        // Dig into the jsonTopLevelDictionary to get the array of articles
        guard let jsonArticlesArray = jsonTopLevelDictionary["articles"] as? [[String: Any]] else {
            print("didn't get array of articles object as JSON from API")
            return .failure(independentAPIManagerError.objectSerialization(reason:
                "Did not get JSON dictionary in response"))
        }
        
        
        
        // turn JSON in to article objects
        var articles = [Article]()
        for item in jsonArticlesArray {
            if let article = Article(json: item) {
                articles.append(article)
            }
        }
        return .success(articles)
    }
}
