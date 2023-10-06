//
//  CharacterViewModel.swift
//  Marvel take home project
//
//  Created by Shubham on 05/10/23.
//

import Foundation
import UIKit

class SpecificCharacterViewModel: NSObject{
    
    weak var vc : CharacterViewController?
    static var savedCharacterModelForSpecificCharacters: CharacterModel?
    
    func callForCharactersAPIForSpecficCharacter(name: String) {
        let myurl = URLLocations.marvelEndPoint + URLLocations.marvelCharacterQueryPoint +  "name=\(name)" + "\(URLLocations.otherParameters)"

        let url = URL(string: myurl)
        
        if let url = url {
            ParsingAPI.call.apiCalling(url: url, methodType: .get, params: [:] , finish: callCharacterAPI)
        }
    }
    
    
    func callCharacterAPI (message:String, AllData:Data?) -> Void
    {
        
        do {
            if message == "400" {
                DispatchQueue.main.async {
                    self.vc?.failedToFetchCharacters()
                }
                return
            }
            
            if let jsonData = AllData
            {
                let myData =  try JSONDecoder().decode(CharacterModel.self, from: jsonData)
                print(myData)
                
                if let data = myData.status {
                    if message == "200" {
                        DispatchQueue.main.async {
                            SpecificCharacterViewModel.savedCharacterModelForSpecificCharacters = myData
                            self.vc?.successToFetchSpecificCharacters()
                        }
                    }
                }
            }
            else {
                // Failure of the parsing json data
                DispatchQueue.main.async {
                    self.vc?.failedToFetchCharacters()
                }
                
            }
        } catch {
            //
            print("Parse Error")
            let error = "\(error)"
            DispatchQueue.main.async {
                self.vc?.failedToFetchCharacters()
            }
            print(error)
        }
        
    }
    
}
