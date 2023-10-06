//
//  ViewController.swift
//  Marvel take home project
//
//  Created by Shubham on 05/10/23.
//

import UIKit

class DashboardViewController: UITabBarController {
    // MARK: Properties

    
    // MARK: Inbuilt Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        setupTabBarController()
    }


    // MARK: Custom Methods
    private func setupTabBarController() {
        let vc1 = UINavigationController(rootViewController: CharacterViewController())
        let vc2 = UINavigationController(rootViewController: ComicViewController())
        
        vc1.navigationBar.prefersLargeTitles = true
        vc2.navigationBar.prefersLargeTitles = true
        
        vc1.tabBarItem = UITabBarItem(title: "Characters", image: UIImage(systemName: "pin.fill"), tag: 0)
        vc2.tabBarItem = UITabBarItem(title: "Comics", image: UIImage(systemName: "mail.fill"), tag: 1)
        
        self.setViewControllers([vc1, vc2], animated: true)
        self.selectedIndex = 0
    }
}












#Preview {
    DashboardViewController()
}
