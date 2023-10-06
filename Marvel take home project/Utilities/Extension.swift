//
//  Extension.swift
//  Uber Practise App
//
//  Created by Shubham on 10/05/22.
//

import UIKit
import CommonCrypto
import Foundation

// MARK: - Extensions
extension UIView {
    
    // Handling Contraints
    func customAnchor(top: NSLayoutYAxisAnchor? = nil,
                      left: NSLayoutXAxisAnchor? = nil, // providing default value
                      bottom: NSLayoutYAxisAnchor? = nil,
                      right: NSLayoutXAxisAnchor? = nil,
                      paddingTop: CGFloat = 0,
                      paddingLeft: CGFloat = 0,
                      paddingBottom: CGFloat = 0,
                      paddingRight: CGFloat = 0,
                      width: CGFloat? = nil,
                      height: CGFloat? = nil) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // top
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        // left
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        // bottom
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        // right
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        // width
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        // height
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    // center function
    func customCenterX(inView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func customCenterY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat = 0.0, constant: CGFloat = 0.0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            customAnchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
}

extension Dictionary{
    
    func jsonParseString() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            // here "jsonData" is the dictionary encoded in JSON data
            
            guard let string = String(data: jsonData, encoding: .utf8) else{
                return nil
            }
            return string
            
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}


extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

extension UIImageView {
    func loadImageFromWeb(str: String) {
        let url = URL(string: str)
        var task: URLSessionDataTask!
        var imageCache = NSCache<AnyObject, AnyObject>()
        self.image = nil
        
        if let task = task {
            task.cancel()
        }
        
        
        if let url = url {
            if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as?  UIImage {
                self.image =  imageFromCache
                return
            }
            
            task = URLSession.shared.dataTask(with: url) { data, res, error in
                guard let data = data, let newImage = UIImage(data: data) else { return }
                
                imageCache.setObject(newImage, forKey: url.absoluteString as AnyObject)
                
                DispatchQueue.main.async {
                    self.image = newImage
                }
            }
            task.resume()
        }
    }
}


extension Calendar {
    /*
    Week boundary is considered the start of
    the first day of the week and the end of
    the last day of the week
    */
    typealias WeekBoundary = (startOfWeek: Date?, endOfWeek: Date?)
    
    func currentWeekBoundary() -> WeekBoundary? {
        return weekBoundary(for: Date())
    }
    
    func weekBoundary(for date: Date) -> WeekBoundary? {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        
        guard let startOfWeek = self.date(from: components) else {
            return nil
        }
        
        let endOfWeekOffset = weekdaySymbols.count - 1
        let endOfWeekComponents = DateComponents(day: endOfWeekOffset, hour: 23, minute: 59, second: 59)
        guard let endOfWeek = self.date(byAdding: endOfWeekComponents, to: startOfWeek) else {
            return nil
        }
        
        return (startOfWeek, endOfWeek)
    }
}

extension Date {
    //previous month start
    func getLastMonthStart() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    //previous month end
    func getLastMonthEnd() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.day = 1
        components.day -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
}
