//
//  CharacterViewModel.swift
//  Marvel take home project
//
//  Created by Shubham on 05/10/23.
//

import Foundation
import UIKit

class ComicViewModel: NSObject{
    
    weak var vc : ComicViewController?
    static var savedComicModel: MarvelGeneralModel?
// https://gateway.marvel.com:443/v1/public/comics?dateRange=2020-01-01%2C2020-01-08&limit=10&offset=0&apikey=ecd4bbfb16615d304bd94469969af0c1

    func callForComicsAPI(startDate: String, endDate: String)
    {
        let myurl = URLLocations.marvelEndPoint + URLLocations.marvelComicQueryPoint + "dateRange=\(startDate)%2C\(endDate)&" + "limit=\(CallComicAPI.limit)&offset=\(CallComicAPI.offset)" + URLLocations.otherParameters
        let url = URL(string: myurl)
        
        if let url = url{
            ParsingAPI.call.apiCalling(url: url, methodType: .get, params: [:] , finish: callComicAPI)
        }
    }
    
    private func callComicAPI (message:String, AllData:Data?) -> Void
    {
        
        do {
            if message == "400" {
                DispatchQueue.main.async {
                    self.vc?.failedToFetchComics()
                }
                return
            }
            
            if let jsonData = AllData
            {
                let myData =  try JSONDecoder().decode(MarvelGeneralModel.self, from: jsonData)
                print(myData)
                
                if myData.status != nil {
                    if message == "200" {
                        DispatchQueue.main.async {
                            ComicViewModel.savedComicModel = myData
                            self.vc?.successToFetchComics()
                        }
                    }
                }
            }
            else {
                // Failure of the parsing json data
                DispatchQueue.main.async {
                    self.vc?.failedToFetchComics()
                }
                
            }
        } catch {
            //
            print("Parse Error")
            let error = "\(error)"
            DispatchQueue.main.async {
                self.vc?.failedToFetchComics()
            }
            print(error)
        }
        
    }
    
}
