//
//  RecordVC.swift
//  teleprompter-ios
//
//  https://sispo.co
//  Created for Robert Savage, Pronunciator, LLC
//  Copyright © 2018 Sispo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import AVFoundation

let defs = UserDefaults.standard

class RecordVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tableView: UITableView!
    var urlField: UITextField?
    let cellID = "id"
    
    var currentType: RecordType = .all
    
    var isEnableBarButton: Bool = true
    
    let searchController = UISearchController(searchResultsController: nil)
    var isInSearch = false
    
    var filteredRecords: [Record] = []
    
    var tableViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle()
        
        configureNavigationItem()
        configureTableView()
        configureConstraints()
        configureKeyboard()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTitle()
    }
    
    func updateTitle() {
        switch currentType {
        case .all:
            title = "All Records" + "(\(RecordService.shared.allRecords.count))"
        case .undone:
            title = "Undone Records" + "(\(RecordService.shared.undoneRecords.count))"
        }
    }
    
    func configureNavigationItem() {
        navigationItem.rightBarButtonItem = isEnableBarButton ? UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openAlertController)) : nil
    }
    
    func configureConstraints() {
        var constrains = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ]
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        constrains.append(tableViewBottomConstraint)
        NSLayoutConstraint.activate(constrains)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func configureTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }
    
    @objc func openAlertController(){
        let addNewFileAlert = UIAlertController(title: "Add a New File", message: nil, preferredStyle: .alert)
        addNewFileAlert.addTextField(configurationHandler: urlField)
        
        let importButton = UIAlertAction(title: "Import", style: .default, handler: self.okHandler(handler:))
        
        addNewFileAlert.addAction(importButton)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        addNewFileAlert.addAction(cancelButton)
        
        self.present(addNewFileAlert, animated: true)
    }
    
    func urlField(textField: UITextField?){
        urlField = textField
        urlField?.placeholder = "URL"
        urlField?.text = "https://www.pronunciator.com/"
    }
    
    func okHandler(handler: UIAlertAction) {
        guard let urlString = urlField?.text, let url = URL.init(string: urlString) else {
            self.showAlert(title: "Error", message: "URL is invalid", completion: nil)
            return
        }
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData.init(size: CGSize.init(width: 70, height: 70), message: nil, messageFont: nil, messageSpacing: nil, type: .circleStrokeSpin, color: .white, padding: 20.0, displayTimeThreshold: 200, minimumDisplayTime: 1000, backgroundColor: UIColor.black.withAlphaComponent(0.7), textColor: nil), nil)
        RecordService.shared.getRecordsFrom(url) { (error) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            guard error == nil else {
                self.showAlert(title: "Error", message: error?.localizedDescription ?? "Failed to get record", completion: nil)
                return
            }
            self.updateTitle()
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isInSearch ? filteredRecords.count :  currentType == .undone ? RecordService.shared.undoneRecords.count : RecordService.shared.allRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let record = isInSearch ? filteredRecords[indexPath.row] : currentType == .undone ? RecordService.shared.undoneRecords[indexPath.row] : RecordService.shared.allRecords[indexPath.row]
        cell.textLabel?.text = record.description
        cell.accessoryType = record.isDone ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = isInSearch ? filteredRecords[indexPath.row] : currentType == .undone ? RecordService.shared.undoneRecords[indexPath.row] : RecordService.shared.allRecords[indexPath.row]
        RecordService.shared.currentMode = currentType == .undone ? .undone : .all
        RecordService.shared.currentRecord = record
        RecordService.shared.shouldPlayNext = true
        self.navigationController?.parent?.dismiss(animated: true, completion: nil)
    }
}


extension RecordVC: UISearchResultsUpdating, UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.setContentOffset(.zero, animated: false)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text != "" {
            isInSearch = true
            filteredRecords = filter(records: currentType == .undone ? RecordService.shared.undoneRecords : RecordService.shared.allRecords, with: text)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            isInSearch = false
            self.tableView.reloadData()
        }
    }
    
    func filter(records: [Record], with text: String) -> [Record] {
        if let index = text.firstIndex(of: "-"), let fromNumber = Int(text.prefix(upTo: index)), let toNumber = Int(text.suffix(from: text.index(index, offsetBy: 1))) {
            return records.filter { $0.number >= fromNumber && $0.number <= toNumber }
        } else if let index = text.firstIndex(of: "+"), let number = Int(text.prefix(upTo: index)) {
            return records.filter { $0.number >= number }
        } else if let number = Int(text) {
            return records.filter { $0.number == number }
        } else {
            return records.filter { $0.text.contains(text) }
        }
    }
}

extension RecordVC {
    
    func configureKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            
            print(endFrameY)
            print(UIScreen.main.bounds.size.height)
            if endFrameY >= UIScreen.main.bounds.size.height {
                tableViewBottomConstraint.constant = 0
            } else {
                tableViewBottomConstraint.constant = -(UIScreen.main.bounds.height - endFrameY)
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
}
