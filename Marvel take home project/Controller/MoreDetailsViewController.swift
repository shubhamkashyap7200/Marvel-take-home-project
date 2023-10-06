//
//  MoreDetailsViewController.swift
//  Marvel take home project
//
//  Created by Shubham on 06/10/23.
//

import Foundation
import UIKit

class MoreDetailsViewController: UIViewController {
    
    var characterNameString: String?
    var characterDescString: String?
    var passedImage: UIImage?
    
    private let screenSize: CGRect = UIScreen.main.bounds

    private let characterName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .heavy)
        return label
    }()
    
    private let characterDescription: UILabel = {
        let label = UILabel()
        return label
    }()
    
    
    private let characterImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        //  Pinning the image to top
        view.addSubview(characterImage)
        characterImage.customAnchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: screenSize.height / 2)
        characterImage.image = passedImage
        
        view.addSubview(characterName)
        characterName.text = characterNameString
        characterName.numberOfLines = 0

        view.addSubview(characterDescription)
        characterDescription.text = characterDescString
        characterDescription.numberOfLines = 0
        
        // Adding blur effect for the photo
        let newImageView = UIImageView(image: passedImage)
        view.addSubview(newImageView)
        newImageView.customAnchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: screenSize.height / 2)

        let visualEffectView = UIVisualEffectView()
        view.addSubview(visualEffectView)
        visualEffectView.effect = UIBlurEffect(style: .regular)
        visualEffectView.customAnchor(top: characterImage.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        let stackView = UIStackView(arrangedSubviews: [characterName, characterDescription])
        view.addSubview(stackView)
        stackView.customAnchor(top: characterImage.bottomAnchor, left: view.leftAnchor, paddingTop: 20.0, paddingLeft: 20)
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        stackView.spacing = 20.0
        stackView.alignment = .leading
        stackView.axis = .vertical
    }
}


#Preview {
    MoreDetailsViewController()
}
