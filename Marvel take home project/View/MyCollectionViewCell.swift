//
//  File.swift
//  Marvel take home project
//
//  Created by Shubham on 06/10/23.
//

import Foundation
import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    lazy var customLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var customDescription: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var customImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 6.0
        self.clipsToBounds = true
        self.addSubview(customImageView)
        self.addSubview(customDescription)
        self.addSubview(customLabel)

        // Image setting
        customImageView.customAnchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor)
        customImageView.contentMode = .scaleAspectFill
        customImageView.clipsToBounds = true
        
        // Name setting
        customLabel.customAnchor(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, height: 40.0)
        customLabel.textAlignment = .center
        customLabel.text = "Loading"
        customLabel.backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    MyCollectionViewCell()
}
