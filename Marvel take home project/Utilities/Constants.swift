//
//  Constants.swift
//  Marvel take home project
//
//  Created by Shubham on 05/10/23.
//

import Foundation

enum HTTPMethodType : String {
    case get = "GET"
    case post = "POST"
}

struct CallCharacterAPI {
    static var limit = 20
    static var offset = 0
}

struct CallComicAPI {
    static var limit = 20
    static var offset = 0
}


