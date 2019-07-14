//
//  PodcastsSearchController.swift
//  PodcastsApp
//
//  Created by Алексей Пархоменко on 07/07/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit
import Alamofire

class PodcastsSearchController: UITableViewController, UISearchBarDelegate {
    
    fileprivate var timer: Timer?
    
    var podcasts = [
        Podcast(trackName: "Lets Build That App", artistName: "Brian Voong"),
        Podcast(trackName: "Some Podcast", artistName: "Some Author"),
    ]
    
    let cellId = "cellId"
    
    // lets implement a UISearchController
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
    }
    
    //MARK:- Setup Work
    
    fileprivate func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
   
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            
            let updatingString = searchText.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil).lowercased()
            
//            let url = "https://itunes.apple.com/search?term=\(updatingString)"
            let url = "https://itunes.apple.com/search"
            let parameters = ["term": searchText, "media": "software"]

            // encoding - меняет пробелы на амперсанты
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
                if let err = dataResponse.error {
                    print("Failed to contact yahoo", err)
                    return
                }
                
                guard let data = dataResponse.data else { return }
                let dummyString = String(data: data, encoding: .utf8)
                //                print(dummyString ?? "")
                
                do {
                    let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                    print("searchResult:\(searchResult)")
                    
                    self.podcasts = searchResult.results
                    self.tableView.reloadData()
                } catch let decodeErr {
                    print("Failed to decode:", decodeErr)
                }
            }
        }) // timer
    }
    
    fileprivate func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    //MARK:- UITableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let podcast = self.podcasts[indexPath.row]
        cell.textLabel?.text = "\(podcast.trackName ?? "")\n\(podcast.artistName ?? "")"
        cell.textLabel?.numberOfLines = 2
        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
        
        return cell
    }
}
