//
//  DetailVC.swift
//  teleprompter-ios
//
//  Created by Вячеслав on 9/29/18.
//  Copyright © 2018 Вячеслав. All rights reserved.
//

import UIKit

class DetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var buttonsTable : UITableView!
    var urlField : UITextField?
    let cellID = "id"
    var allRecords : [String] = [String]()
    var undoneRecords : [String] = [String]()
    var selected : [String] = [String]()
    
    var isEnableBarButton : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = isEnableBarButton == true ? UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openAlertController)) : nil
        buttonsTable = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
        buttonsTable.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        buttonsTable.dataSource = self
        buttonsTable.delegate = self
        view.addSubview(buttonsTable)
        buttonsTable.translatesAutoresizingMaskIntoConstraints = false
        
        let constrains = [
            buttonsTable.topAnchor.constraint(equalTo: view.topAnchor),
            buttonsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonsTable.leftAnchor.constraint(equalTo: view.leftAnchor),
            buttonsTable.rightAnchor.constraint(equalTo: view.rightAnchor),
            buttonsTable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsTable.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ]
        NSLayoutConstraint.activate(constrains)
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
    }
    
    func okHandler(handler: UIAlertAction){
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selected.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = buttonsTable.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = selected[indexPath.row]
        return cell
    }
    
}
