//
//  CharacterViewController.swift
//  Marvel take home project
//
//  Created by Shubham on 05/10/23.
//

import Foundation
import UIKit
import UIScrollView_InfiniteScroll

import UIKit

class CharacterViewController: UIViewController {
    // MARK: Properties
    
    let characterVM = CharacterViewModel()
    let specificCharacterVM = SpecificCharacterViewModel()
    var tableViewSearchHistoryArray = [String]()

    private var searching = false
    private var searchedArray = [String]()
    private let screenSize: CGRect = UIScreen.main.bounds
    fileprivate let cellReuseIdentifier = "collectionCell"
    fileprivate let cellReuseIdentifierForTableView = "tableCell"
    
    private var allCharacterSimplifiedModelArray = [CharacterSimplifiedModel]()
    private var specificCharacterSimplifiedModelArray = [CharacterSimplifiedModel]()
    
    private lazy var customSearchBarHistoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var customCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 180)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Adding pagnation
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.infiniteScrollDirection = .vertical
        collectionView.addInfiniteScroll { [weak self]colView in
            // Fetch more data by calling api
            
            CallCharacterAPI.limit += 20
            CallCharacterAPI.offset += 20
            
            self?.callForCharactersAPI()
            
            // Add cells
            
        }
        
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return collectionView
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableViewSearchHistoryArray = UserDefaults.standard.value(forKey: "tableViewSearchHistory") as? [String] ?? []

        view.addSubview(customCollectionView)
        view.addSubview(customSearchBarHistoryTableView)
        
        customCollectionView.customAnchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        customCollectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        
        customSearchBarHistoryTableView.customAnchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)

        navigationController?.navigationBar.topItem?.title = "Characters"
        
        configureSearchController()
        customSearchBarHistoryTableView.isHidden = true
        
        // Network call
        callForCharactersAPI()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func configureSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.returnKeyType = .done
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Search character by name"
    }
}

// MARK: Table View search history functions
extension CharacterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewSearchHistoryArray.count > 0 ? tableViewSearchHistoryArray.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = tableViewSearchHistoryArray.reversed()[indexPath.row]
        
        
//
//        var tableViewSearchHistoryArray = [String]()
//        tableViewSearchHistoryArray = UserDefaults.standard.value(forKey: "tableViewSearchHistory") as? [String] ?? []
//        
//        if !tableViewSearchHistoryArray.isEmpty {
//            cell.customLabel.text = tableViewSearchHistoryArray.reversed()[indexPath.row]
//        }
//        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        // Call api again if user press the any cell
        if let text = cell?.textLabel?.text {
            
            if customCollectionView.isHidden == true {
                customCollectionView.isHidden = false
                customSearchBarHistoryTableView.isHidden = true
                searchController.isActive = false
            }

            searchController.searchBar.text = text
            
            callForCharactersAPIForSpecficCharacter(name: text)
        }
    }
}

extension CharacterViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        if !searchText.isEmpty {
            searching = true
//            specificCharacterSimplifiedModelArray.removeAll()
        } else {
            searching = false
            specificCharacterSimplifiedModelArray.removeAll()
        }
        
        customCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Pressed the done key
        if customCollectionView.isHidden == true {
            customCollectionView.isHidden = false
            customSearchBarHistoryTableView.isHidden = true
        }
        
        if let text = searchBar.text {
            if text != "" {
                
                tableViewSearchHistoryArray = UserDefaults.standard.value(forKey: "tableViewSearchHistory") as? [String] ?? []
                tableViewSearchHistoryArray.append(text)
                UserDefaults.standard.setValue(tableViewSearchHistoryArray, forKey: "tableViewSearchHistory")
                
                callForCharactersAPIForSpecficCharacter(name: text)
                customSearchBarHistoryTableView.reloadData()
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if tableViewSearchHistoryArray.count > 0 {
            if customCollectionView.isHidden == false {
                customCollectionView.isHidden = true
                customSearchBarHistoryTableView.isHidden = false
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if customCollectionView.isHidden == true {
            customCollectionView.isHidden = false
            customSearchBarHistoryTableView.isHidden = true
        }
    }
}

extension CharacterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! MyCollectionViewCell
        
        if searching {
            if specificCharacterSimplifiedModelArray.count > 0 {
                if let name = specificCharacterSimplifiedModelArray[indexPath.row].name,
                   let desc = specificCharacterSimplifiedModelArray[indexPath.row].description,
                   let img = specificCharacterSimplifiedModelArray[indexPath.row].image
                {
                    cell.customLabel.text = name
                    cell.customImageView.loadImageFromWeb(str: img)
                    cell.customDescription.text = desc
                }
            }
        }
        else {
            if allCharacterSimplifiedModelArray.count > 0 {
                if let name = allCharacterSimplifiedModelArray[indexPath.row].name,
                   let desc = allCharacterSimplifiedModelArray[indexPath.row].description,
                   let img = allCharacterSimplifiedModelArray[indexPath.row].image
                {
                    cell.customLabel.text = name
                    cell.customImageView.loadImageFromWeb(str: img)
                    cell.customDescription.text = desc
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searching {
            return specificCharacterSimplifiedModelArray.count > 0 ? specificCharacterSimplifiedModelArray.count : 0
        } else {
            return allCharacterSimplifiedModelArray.count > 0 ? allCharacterSimplifiedModelArray.count : 10
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 20, left: 8, bottom: 5, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MyCollectionViewCell
        if allCharacterSimplifiedModelArray.count > 0 {
            let vc = MoreDetailsViewController()
            vc.characterNameString = cell.customLabel.text
            vc.characterDescString = cell.customDescription.text
            vc.passedImage = cell.customImageView.image
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}


// MARK: Network Calls
extension CharacterViewController {
    func callForCharactersAPIForSpecficCharacter(name: String) {
        specificCharacterVM.vc = self
        specificCharacterVM.callForCharactersAPIForSpecficCharacter(name: name)
    }

    func callForCharactersAPI() {
        characterVM.vc = self
        characterVM.callForCharactersAPI()
    }
    
    
    // Success methods
    func successToFetchCharacters() {
        print("DEBUG:NETWORK - This is a success from characters api")
        
        if let dataFromCharacterModel = CharacterViewModel.savedCharacterModel {
            var simplifiedCharacterModel = CharacterSimplifiedModel()
            
            if let results = dataFromCharacterModel.data?.results {
                for (_,res) in results.enumerated() {
                    if let name = res.name, let imgPath = res.thumbnail?.path, let imgExtension = res.thumbnail?.extensions, let desc = res.description {
                        simplifiedCharacterModel.name = name
                        simplifiedCharacterModel.description = desc
                        simplifiedCharacterModel.image = imgPath + "." + imgExtension
                        
                        allCharacterSimplifiedModelArray.append(simplifiedCharacterModel)
                    }
                }
            }
            
            
            customCollectionView.reloadData()
            
            // finish the infinite loop
            customCollectionView.finishInfiniteScroll()

        }
    }
    
    func successToFetchSpecificCharacters() {
        print("DEBUG:NETWORK - This is a success from characters api")
        
        if let dataFromCharacterModel = SpecificCharacterViewModel.savedCharacterModelForSpecificCharacters {
            var simplifiedCharacterModel = CharacterSimplifiedModel()
            
            if let results = dataFromCharacterModel.data?.results {
                for (_,res) in results.enumerated() {
                    if let name = res.name, let imgPath = res.thumbnail?.path, let imgExtension = res.thumbnail?.extensions, let desc = res.description {
                        simplifiedCharacterModel.name = name
                        simplifiedCharacterModel.description = desc
                        simplifiedCharacterModel.image = imgPath + "." + imgExtension
                        
                        specificCharacterSimplifiedModelArray.append(simplifiedCharacterModel)
                    }
                }
            }
            
            // Filling the array
            print("VALUES ARE HERE :: \(specificCharacterSimplifiedModelArray)")
            customCollectionView.reloadData()
        }
    }

    
    // failure methods
    func failedToFetchCharacters() {
        print("DEBUG:NETWORK - This is a failure from characters api")
    }
}

#Preview {
    CharacterViewController()
}
