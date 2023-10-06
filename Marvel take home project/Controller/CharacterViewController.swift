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
    var spinnerChild = SpinnerViewController()

    private let characterVM = CharacterViewModel()
    private let specificCharacterVM = SpecificCharacterViewModel()
    private var tableViewSearchHistoryArray = [String]()
    private var searching = false
    private var searchedArray = [String]()
    private let screenSize: CGRect = UIScreen.main.bounds
    private let searchController = UISearchController(searchResultsController: nil)

    fileprivate let cellReuseIdentifier = "collectionCell"
    fileprivate let cellReuseIdentifierForTableView = "tableCell"
    
    // For both if searched or not searched model files
    private var allCharacterSimplifiedModelArray = [SimplifiedModel]()
    private var specificCharacterSimplifiedModelArray = [SimplifiedModel]()
    
    // Table view for the history of the search bar
    private lazy var customSearchBarHistoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    // Initiase collection view / grid view
    private lazy var customCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 110, height: 180)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Adding pagnation using third party library
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.infiniteScrollDirection = .vertical
        collectionView.addInfiniteScroll { [weak self] colView in
            // Fetch more data by calling api
            
            CallCharacterAPI.limit += 20
            CallCharacterAPI.offset += 20
            
            self?.callForCharactersAPI()
                        
        }
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return collectionView
    }()
        
    func addSpinnerView() {
        // add the spinner view controller
        addChild(spinnerChild)
        spinnerChild.view.frame = view.frame
        view.addSubview(spinnerChild.view)
        spinnerChild.didMove(toParent: self)
    }
    
    func removeSpinnerView() {
        // then remove the spinner view controller
        spinnerChild.willMove(toParent: nil)
        spinnerChild.view.removeFromSuperview()
        spinnerChild.removeFromParent()
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Characters"

        // Getting all stored history entry from user defaults
        tableViewSearchHistoryArray = UserDefaults.standard.value(forKey: "tableViewSearchHistory") as? [String] ?? []

        // adding both collection and table view to view
        view.addSubview(customCollectionView)
        view.addSubview(customSearchBarHistoryTableView)
        
        // adding constraints and registring the collection view cell
        customCollectionView.customAnchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        customCollectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        // adding constratins to table view and hiding it initialy
        customSearchBarHistoryTableView.customAnchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        customSearchBarHistoryTableView.isHidden = true

        // adding search bar
        configureSearchController()
        
        // Network call for first 20 characters
        addSpinnerView()
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        // Call api again if user press the any cell
        addSpinnerView()
        
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


// MARK: Search bar functions
extension CharacterViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        if !searchText.isEmpty {
            searching = true
        } else {
            searching = false
            specificCharacterSimplifiedModelArray.removeAll()
        }
        
        customCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Pressed the done key
        addSpinnerView()
        
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

// MARK: Collection view delegates and datasource
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
            var simplifiedCharacterModel = SimplifiedModel()
            
            if let results = dataFromCharacterModel.data?.results {
                for (_,res) in results.enumerated() {
                    if let name = res.name, let imgPath = res.thumbnail?.path, let imgExtension = res.thumbnail?.extensions {
                        simplifiedCharacterModel.name = name
                        simplifiedCharacterModel.description = res.description ?? "No Description available"
                        simplifiedCharacterModel.image = imgPath + "." + imgExtension
                        
                        allCharacterSimplifiedModelArray.append(simplifiedCharacterModel)
                    }
                }
            }
            
            
            customCollectionView.reloadData()
            
            // finish the infinite loop
            customCollectionView.finishInfiniteScroll()
            removeSpinnerView()

        }
    }
    
    func successToFetchSpecificCharacters() {
        print("DEBUG:NETWORK - This is a success from characters api")
        
        if let dataFromCharacterModel = SpecificCharacterViewModel.savedCharacterModelForSpecificCharacters {
            var simplifiedCharacterModel = SimplifiedModel()
            
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
            removeSpinnerView()
        }
    }

    
    // failure methods
    func failedToFetchCharacters() {
        print("DEBUG:NETWORK - This is a failure from characters api")
        removeSpinnerView()
    }
}
