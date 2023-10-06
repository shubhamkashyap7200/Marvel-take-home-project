//
//  Thumbnail.swift
//  Marvel take home project
//
//  Created by Shubham on 05/10/23.
//

import Foundation

struct Thumbnail: Codable {
    
    var path      : String?
    var extensions : String?
    
    enum CodingKeys: String, CodingKey {
        
        case path      = "path"
        case extensions = "extension"
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        path      = try values.decodeIfPresent(String.self , forKey: .path      )
        extensions = try values.decodeIfPresent(String.self , forKey: .extensions )
        
    }
    
    
    
}
