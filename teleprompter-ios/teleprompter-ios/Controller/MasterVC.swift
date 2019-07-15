//
//  MasterVC.swift
//  teleprompter-ios
//
//  https://sispo.co
//  Created for Robert Savage, Pronunciator, LLC
//  Copyright © 2018 Sispo. All rights reserved.
//

import UIKit

enum RecordType {
    case all
    case undone
}

class MasterVC: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var menuButtonsTable : UITableView!
    let cellID = "id"
    let menuItems = ["All Records", "Undone records", "Settings", "AirTurn"]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Menu"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(cancel))
        
        menuButtonsTable = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
        menuButtonsTable.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        menuButtonsTable.separatorStyle = .none
        menuButtonsTable.dataSource = self
        menuButtonsTable.delegate = self

        view.addSubview(menuButtonsTable)
        menuButtonsTable.translatesAutoresizingMaskIntoConstraints = false

        let constrains = [
            menuButtonsTable.topAnchor.constraint(equalTo: view.topAnchor),
            menuButtonsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            menuButtonsTable.leftAnchor.constraint(equalTo: view.leftAnchor),
            menuButtonsTable.rightAnchor.constraint(equalTo: view.rightAnchor),
        ]
        NSLayoutConstraint.activate(constrains)

        presentRecordScreen(type: .all)
    }

    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = menuButtonsTable.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    
    func presentRecordScreen(type: RecordType) {
        let recordVC = RecordVC()
        recordVC.currentType = type
        self.showDetailViewController(UINavigationController(rootViewController: recordVC) ,sender: self)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let settingsVC: SettingsVC = SettingsVC()
            settingsVC.title = menuItems[indexPath.row]
            self.showDetailViewController(UINavigationController(rootViewController: settingsVC) ,sender: self)
        } else if indexPath.row == 3 {
            let atUICC = AirTurnUIConnectionController.init(supportingKeyboardAirTurn: true, airDirectAirTurn: true)
            self.showDetailViewController(UINavigationController(rootViewController: atUICC) ,sender: self)
        } else {
            presentRecordScreen(type: indexPath.row == 0 ? .all : .undone)
        }
    }

}
