//
//  Urls.swift
//  Marvel take home project
//
//  Created by Shubham on 05/10/23.
//
import Foundation

struct Urls: Codable {
    
    var type : String?
    var url  : String?
    
    enum CodingKeys: String, CodingKey {
        
        case type = "type"
        case url  = "url"
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        type = try values.decodeIfPresent(String.self , forKey: .type )
        url  = try values.decodeIfPresent(String.self , forKey: .url  )
        
    }
    
    
    
}
