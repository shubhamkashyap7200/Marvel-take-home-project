//
//  Items.swift
//  Marvel take home project
//
//  Created by Shubham on 05/10/23.
//
import Foundation

struct Items: Codable {
    
    var resourceURI : String? = nil
    var name        : String? = nil
    
    enum CodingKeys: String, CodingKey {
        
        case resourceURI = "resourceURI"
        case name        = "name"
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        resourceURI = try values.decodeIfPresent(String.self , forKey: .resourceURI )
        name        = try values.decodeIfPresent(String.self , forKey: .name        )
        
    }
    
    
    
}
