//
//  File.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

final class SearchTableViewController: UIViewController, UISearchBarDelegate, Alertable, UniqueIdHelper {
    
    static var uniqueID: String = "searchTableVC"
    @IBOutlet var searchTableView: UITableView!
    let searchBar = UISearchBar()
    
    private var data: [Any] = []
    var sectionsData = [[], [], []]
    private var selectedSection: Int = 0

    
    fileprivate var searchWorkTask: DispatchWorkItem?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTableView.dataSource = self
        self.searchTableView.delegate = self
        view.backgroundColor = .black
        UISearchBar.appearance().tintColor = UIColor.red //cancel button color
        setUpNavBar()

    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    func setUpNavBar() {
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search by "
        searchBar.backgroundColor = UIColor.darkColor
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.lightGray
        navigationItem.titleView = searchBar
        searchBar.isTranslucent = true
    }
    
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkTask?.cancel()
        
        let newTask = DispatchWorkItem { [weak self] in
            self?.searchByKeyword(queryText: searchText)
        }
        
        searchWorkTask = newTask
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: newTask)
    }
    
    fileprivate func searchByKeyword (queryText: String) {
        ApiService.shared.searchMedia(query: queryText, completionHandler: { (searchData) in
           self.data = searchData
           self.sectionsData = [[], [], []]
            for item in searchData {
                if item is Movie {
                    self.sectionsData[0].append(item)
                } else if item is TvShow {
                    self.sectionsData[1].append(item)
                } else if item is Person {
                    self.sectionsData[2].append(item)
                }
            }
            self.searchTableView.reloadData()
        }) { (err) in
            self.showAlert("Error", err)
        }
    }
}


extension SearchTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsData[selectedSection].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell( withIdentifier: "idCell" ) as! MovieSearchCell
        
        if  selectedSection == 0 {
            let cellData = sectionsData[selectedSection][indexPath.row]
            cell.nameLabel.text = (cellData as! Movie).title
            let posterPath = URL(string: (cellData as! Movie).imageUrl ?? "")
            cell.movieImageView.sd_setImage(with: posterPath, placeholderImage: UIImage(named: "placeholder.png"))
            cell.backgroundColor = UIColor.darkColor
            return cell
        }
        else if selectedSection == 1 {
            let cellData = sectionsData[selectedSection][indexPath.row]
            cell.nameLabel.text = (cellData as! TvShow).title
            let posterPath = URL(string: (cellData as! TvShow).imageUrl ?? "")
            cell.movieImageView.sd_setImage(with: posterPath, placeholderImage: UIImage(named: "placeholder.png"))
            cell.backgroundColor = UIColor.darkColor
            return cell
        } else if selectedSection == 2 {
            let cellData = sectionsData[selectedSection][indexPath.row]
            cell.nameLabel.text = (cellData as! Person).name
            let posterPath = URL(string: (cellData as! Person).avatarURL )
            cell.movieImageView.sd_setImage(with: posterPath, placeholderImage: UIImage(named: "placeholder.png"))
            cell.backgroundColor = UIColor.darkColor
            return cell
        }
        
        return UITableViewCell()
    }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let control = UISegmentedControl(items: ["Movie", "TV Show", "Actors"])
            control.backgroundColor = UIColor.black
            control.tintColor = UIColor.darkColor
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .normal)
        
            control.addTarget(self, action: #selector(valueChanged), for: UIControl.Event.valueChanged)
            if (section == 0) {
               return control
            }
            return nil
       }

    @objc func valueChanged(segmentedControl: UISegmentedControl) {
        print("Coming in : \(segmentedControl.selectedSegmentIndex)")
        self.selectedSection = segmentedControl.selectedSegmentIndex
        self.searchTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if selectedSection == 2 {
            let person = sectionsData[selectedSection][indexPath.section]
            let personVC = PersonViewController()
            personVC.person = person as? Person
            self.navigationController?.pushViewController(personVC, animated: true)
        } else {
            let movieData = sectionsData[selectedSection][indexPath.section]
            if let movieVC = storyboard.instantiateViewController(withIdentifier: MovieViewController.uniqueID) as? MovieViewController {
                movieVC.media = movieData as? MediaData
                self.navigationController?.pushViewController(movieVC, animated: true)
            }
        }
    }

}
