//
//  Article.swift
//  pagesuiteTestApplication
//
//  Created by Danyal Aboobakar on 09/03/2017.
//  Copyright © 2017 Danyal Aboobakar. All rights reserved.
//

import Foundation

class Article {
    var id: String?
    var headline: String?
    var section: String?
    var authorNames: [String] = []
    var url: String?
    var imageURL: String?
    
    required init() {
        
    }
    
    required init?(json: [String: Any]) {
        guard let headline = json["headline"] as? String,
            let section = json["section"] as? String,
            let idValue = json["guid"] as? String,
            let url = json["url"] as? String else {
                return nil
        }
        
        self.headline = headline
        self.id = idValue
        self.url = url
        self.section = section
        
        if let ownerJson = json["image"] as? [String: Any] {
            self.imageURL = ownerJson["thumbnail"] as? String
        }
        
        if let authorsJson = json["authors"] as? [[String: Any]] {
            for item in authorsJson {
                if let name = item["name"] as? String {
                    authorNames.append(name)
                }
            }
        }
    }
}



