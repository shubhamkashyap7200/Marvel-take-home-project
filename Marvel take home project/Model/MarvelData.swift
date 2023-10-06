//
//  Data.swift
//  Marvel take home project
//
//  Created by Shubham on 05/10/23.
//
import Foundation

struct MarvelData: Codable {
    
    var offset  : Int?
    var limit   : Int?
    var total   : Int?
    var count   : Int?
    var results : [Results]?
    
    enum CodingKeys: String, CodingKey {
        
        case offset  = "offset"
        case limit   = "limit"
        case total   = "total"
        case count   = "count"
        case results = "results"
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        offset  = try values.decodeIfPresent(Int.self    , forKey: .offset  )
        limit   = try values.decodeIfPresent(Int.self    , forKey: .limit   )
        total   = try values.decodeIfPresent(Int.self    , forKey: .total   )
        count   = try values.decodeIfPresent(Int.self    , forKey: .count   )
        results = try values.decodeIfPresent([Results].self , forKey: .results )
        
    }
    
    
    
}
