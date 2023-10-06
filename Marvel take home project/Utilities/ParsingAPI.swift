//
//  ParsingAPI.swift
//  Marvel take home project
//
//  Created by Shubham on 05/10/23.
//

import Foundation
import UIKit

class ParsingAPI : NSObject,URLSessionDataDelegate,URLSessionDelegate
{
    
    static var call = ParsingAPI()
    
    func apiCalling(url:URL, methodType: HTTPMethodType, params:[String:Any], finish: @escaping ((message:String, AllData:Data?)) -> Void)
       {
           let reqUrl = url
           let reqDict = params
           do {
               let jsonString = reqDict.jsonParseString()
               print(jsonString)
               
               let escapedUrlString = "\(jsonString!.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range: nil))"
               var request = URLRequest(url: reqUrl, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60)
               request.httpMethod = methodType.rawValue
               let requestData: Data? = escapedUrlString.data(using: String.Encoding.utf8)
               if reqDict.count > 0 { request.httpBody = requestData }
               request.setValue("application/json", forHTTPHeaderField: "Content-Type")
               dump(request)
               
               print("---------- Api Request Dump ---------")
               dump(request)
               
               //SESSION
                let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
                var result:(message:String, AllData:Data?) = (message: "Fail", AllData: nil)
                let task = session.dataTask(with: request) { data, response, error in
                    
                    let resp = response as? HTTPURLResponse
                    let statusCode = resp?.statusCode ?? 0
                    result.message = "\(statusCode)"
                    
                   if(error != nil)
                   {
                       print("Error not null : ", error.debugDescription)
                   }
                   else
                   {
                        print(data)
                        print(response)
                       result.AllData = data
                       print(String(data: data!, encoding: .utf8))
                   }
                   
                   finish(result)
               }
               task.resume()
           }
           catch{
               print(exception())
           }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("didBecomeInvalidWithError: \(error?.localizedDescription ?? "")")
    }
        
}

