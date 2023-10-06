//
//  Comics.swift
//  Marvel take home project
//
//  Created by Shubham on 05/10/23.
//
import Foundation

struct Comics: Codable {
    
    var available     : Int?
    var returned      : Int?
    var collectionURI : String?
    var items         : [Items]?
    
    enum CodingKeys: String, CodingKey {
        
        case available     = "available"
        case returned      = "returned"
        case collectionURI = "collectionURI"
        case items         = "items"
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        available     = try values.decodeIfPresent(Int.self  , forKey: .available     )
        returned      = try values.decodeIfPresent(Int.self  , forKey: .returned      )
        collectionURI = try values.decodeIfPresent(String.self  , forKey: .collectionURI )
        items         = try values.decodeIfPresent([Items].self , forKey: .items         )
        
    }
    
    
    
}
