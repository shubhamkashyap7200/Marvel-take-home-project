//
//  URLLocations.swift
//  Marvel take home project
//
//  Created by Shubham on 05/10/23.
//

import Foundation


struct URLLocations {
    // MARK: Keys
    static var publicAPIKey = "ecd4bbfb16615d304bd94469969af0c1"
    static var privateAPIKey = "66782a7c79a8f309312a959f6a7166c27cff982a"
    static var ts = Date().timeIntervalSince1970.description
    static var hash = "\(ts)\(privateAPIKey)\(publicAPIKey)".md5
    static var otherParameters = "&ts=\(ts)&apikey=\(publicAPIKey)&hash=\(hash)"
    
    // MARK: URL
    static var marvelEndPoint = "https://gateway.marvel.com:443/"
    static var marvelCharacterQueryPoint = "v1/public/characters?"
    static var marvelComicQueryPoint = "v1/public/comics?"    
}
