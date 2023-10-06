//
//  ComicViewController.swift
//  Marvel take home project
//
//  Created by Shubham on 05/10/23.
//

import Foundation
import UIKit
import UIScrollView_InfiniteScroll


enum MenuTitle : String {
    case thisWeek = "This week"
    case lastWeek = "Last week"
    case upcomingWeek = "Upcoming week"
    case lastMonth = "Last month"
}

class ComicViewController: UIViewController {
    // MARK: Properties
    private var child = SpinnerViewController()
    fileprivate let cellReuseIdentifier = "collectionCell"
    private var allComicsSimplifiedModelArray = [SimplifiedModel]()
    private let comicVM = ComicViewModel()
    let dateFormatter = DateFormatter()
    let calendar = Calendar.current
    let menuTitle: MenuTitle = .thisWeek
    
    // Initiase collection view / grid view
    private lazy var customCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 180)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Adding pagnation using third party library
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.infiniteScrollDirection = .vertical
        collectionView.addInfiniteScroll { [weak self]colView in
            // Fetch more data by calling api
            
            CallComicAPI.limit += 20
            CallComicAPI.offset += 20
            
            if self?.menuTitle == .thisWeek {
                self?.callForComicsAPILastWeek()
                
            } else if self?.menuTitle == .lastWeek {
                self?.callForComicsAPILastWeek()

            } else if self?.menuTitle == .upcomingWeek {
                self?.callForComicsAPIUpcomingWeek()

            } else if self?.menuTitle == .lastMonth {
                self?.callForComicsAPILastMonth()

            }
            
        }
        
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return collectionView
    }()
    
    func addSpinnerView() {
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func removeSpinnerView() {
        // then remove the spinner view controller
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }

    var menuItems: [UIAction] {
        return [
            UIAction(title: "This week", image: nil, handler: { (_) in
                // This week calling the api and filtering the result
                self.addSpinnerView()
                self.allComicsSimplifiedModelArray.removeAll()
                self.callForComicsAPIThisWeek()
            }),
            UIAction(title: "Last week", image: nil, handler: { (_) in
                // This week calling the api and filtering the result
                self.addSpinnerView()
                self.allComicsSimplifiedModelArray.removeAll()
                self.callForComicsAPILastWeek()
            }),
            UIAction(title: "Upcoming week", image: nil, handler: { (_) in
                // This week calling the api and filtering the result
                self.addSpinnerView()
                self.allComicsSimplifiedModelArray.removeAll()
                self.callForComicsAPIUpcomingWeek()
            }),
            UIAction(title: "Last month", image: nil, handler: { (_) in
                // This week calling the api and filtering the result
                self.addSpinnerView()
                self.allComicsSimplifiedModelArray.removeAll()
                self.callForComicsAPILastMonth()
            })
        ]
    }
    
    var filterMenu: UIMenu {
        return UIMenu(title: "Filter Menu", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", image: UIImage(systemName: "line.3.horizontal.decrease.circle"), primaryAction: nil, menu: filterMenu)
        navigationController?.navigationBar.topItem?.title = "Comics"
        
        dateFormatter.calendar = .init(identifier: .iso8601)
        dateFormatter.locale = .init(identifier: "en_IN")
        dateFormatter.dateFormat = "yyyy-MM-dd"

        
        view.addSubview(customCollectionView)
        
        // adding constraints and registring the collection view cell
        customCollectionView.customAnchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        customCollectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        addSpinnerView()
        callForComicsAPIThisWeek()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
}


// MARK: Collection view delegates and datasource
extension ComicViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! MyCollectionViewCell
        
        if allComicsSimplifiedModelArray.count > 0 {
            if let name = allComicsSimplifiedModelArray[indexPath.row].name,
               let desc = allComicsSimplifiedModelArray[indexPath.row].description,
               let img = allComicsSimplifiedModelArray[indexPath.row].image
            {
                cell.customLabel.text = name
                cell.customImageView.loadImageFromWeb(str: img)
                cell.customDescription.text = desc
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allComicsSimplifiedModelArray.count > 0 ? allComicsSimplifiedModelArray.count : 10
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
        if allComicsSimplifiedModelArray.count > 0 {
            let vc = MoreDetailsViewController()
            vc.characterNameString = cell.customLabel.text
            vc.characterDescString = cell.customDescription.text
            vc.passedImage = cell.customImageView.image
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}


// MARK: Network Calls
extension ComicViewController {
    func callForComicsAPIThisWeek() {
        
        let currentWeekBoundary = Calendar.current.weekBoundary(for: Date.now)
        var startDate = ""
        var endDate = ""

        if let weekStartDate = currentWeekBoundary?.startOfWeek, let weekEndDate = currentWeekBoundary?.endOfWeek {
            startDate = dateFormatter.string(from: weekStartDate)
            endDate = dateFormatter.string(from: weekEndDate)
        }
        
        callForComicsAPI(startDate: startDate, endDate: endDate)
    }
    
    func callForComicsAPILastWeek() {
        let lastWeekDate = Calendar(identifier: .iso8601).date(byAdding: .weekOfYear, value: -1, to: Date())!
        
        let lastWeekBoundary = Calendar.current.weekBoundary(for: lastWeekDate)
        var startDate = ""
        var endDate = ""
        
        if let weekStartDate = lastWeekBoundary?.startOfWeek, let weekEndDate = lastWeekBoundary?.endOfWeek {
            startDate = dateFormatter.string(from: weekStartDate)
            endDate = dateFormatter.string(from: weekEndDate)
        }
        
        callForComicsAPI(startDate: startDate, endDate: endDate)
    }
    
    func callForComicsAPIUpcomingWeek() {
        let nextWeekDate = Calendar(identifier: .iso8601).date(byAdding: .weekOfYear, value: 1, to: Date())!
        
        let nextWeekBoundary = Calendar.current.weekBoundary(for: nextWeekDate)
        var startDate = ""
        var endDate = ""
        
        if let weekStartDate = nextWeekBoundary?.startOfWeek, let weekEndDate = nextWeekBoundary?.endOfWeek {
            startDate = dateFormatter.string(from: weekStartDate)
            endDate = dateFormatter.string(from: weekEndDate)
        }
        
        callForComicsAPI(startDate: startDate, endDate: endDate)
    }
    
    func callForComicsAPILastMonth() {
        let lastMonthStartDate = Date().getLastMonthStart()
        let lastMonthEndDate = Date().getLastMonthEnd()
        
        let lastMonthStartDateString = dateFormatter.string(from: lastMonthStartDate ?? Date())
        let lastMonthEndDateString = dateFormatter.string(from: lastMonthEndDate ?? Date())

        
        var startDate = lastMonthStartDateString
        var endDate = lastMonthEndDateString
        
        callForComicsAPI(startDate: startDate, endDate: endDate)
    }


    
    //    func callForComicsAPILastWeek() {
    //        let startDate = Date.now
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.calendar = .init(identifier: .iso8601)
    //        dateFormatter.locale = .init(identifier: "en_US_POSIX")
    //        dateFormatter.dateFormat = "yyyy-MM-dd"
    //        let todayDate = dateFormatter.string(from: startDate)
    //
    //        print("DATE ::: \(todayDate)")
    //
    //
    //        let lastWeekDate = Calendar(identifier: .iso8601).date(byAdding: .weekOfYear, value: -1, to: Date())!
    //        dateFormatter.calendar = .init(identifier: .iso8601)
    //        dateFormatter.locale = .init(identifier: "en_US_POSIX")
    //        dateFormatter.dateFormat = "yyyy-MM-dd"
    //        let lastWeekDateString = dateFormatter.string(from: lastWeekDate)
    //
    //        print("DATE ::: \(lastWeekDateString)")
    //
    //        callForComicsAPI(startDate: lastWeekDateString, endDate: todayDate)
    //    }
    
    
    func callForComicsAPI(startDate: String, endDate: String) {
        comicVM.vc = self
        comicVM.callForComicsAPI(startDate: startDate, endDate: endDate)
    }
    
    
    // Success methods
    func successToFetchCmoics() {
        print("Success to get comics")
        
        if let dataFromComicModel = ComicViewModel.savedComicModel {
            var simplifiedCharacterModel = SimplifiedModel()
            
            if let results = dataFromComicModel.data?.results {
                for (_,res) in results.enumerated() {
                    if let name = res.title, let imgPath = res.thumbnail?.path, let imgExtension = res.thumbnail?.extensions, let desc = res.description {
                        simplifiedCharacterModel.name = name
                        simplifiedCharacterModel.description = desc
                        simplifiedCharacterModel.image = imgPath + "." + imgExtension
                        
                        allComicsSimplifiedModelArray.append(simplifiedCharacterModel)
                    }
                }
            }
            
            
            customCollectionView.reloadData()
            removeSpinnerView()
            
            // finish the infinite loop
            customCollectionView.finishInfiniteScroll()
            
        }
        
    }
    
    func failedToFetchComics(){
        print("Failure to get comics")
        removeSpinnerView()
    }
}

#Preview {
    ComicViewController()
}
