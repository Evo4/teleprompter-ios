//
//  SettingsVC.swift
//  teleprompter-ios
//
//  https://sispo.co
//  Created for Robert Savage, Pronunciator, LLC
//  Copyright © 2018 Sispo. All rights reserved.
//

import UIKit

enum Pause: String {
    case betweenPhrases = "Pause Time Between Phrases (s)"
    case tts = "Pause Time after TTS (s)"
}

class SettinsTableViewCell: UITableViewCell {
    
    var pauseTimeTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
        textField.keyboardType = UIKeyboardType.numberPad
        textField.textAlignment = .right
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var currentPause: Pause = .betweenPhrases
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        pauseTimeTextField.addTarget(self, action: #selector(saveText), for: .editingChanged)
    }
    
    func configure(pause: Pause) {
        currentPause = pause
        switch pause {
        case .betweenPhrases:
            pauseTimeTextField.text = String(RecordService.shared.pauseTimeBetweenPhrases)
        case .tts:
            pauseTimeTextField.text = String(RecordService.shared.pauseTTS)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        addSubview(pauseTimeTextField)
        let constrains = [
            pauseTimeTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            pauseTimeTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -11),
            pauseTimeTextField.leftAnchor.constraint(equalTo: self.leftAnchor),
            pauseTimeTextField.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -7),
        ]
        NSLayoutConstraint.activate(constrains)
    }
    
    @objc func saveText(){
        if let text = pauseTimeTextField.text, let seconds = Double.init(text) {
            switch currentPause {
            case .betweenPhrases:
                RecordService.shared.pauseTimeBetweenPhrases = seconds
            case .tts:
                RecordService.shared.pauseTTS = seconds
            }
        }
    }
    
}

class SettingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var buttonsTable : UITableView!
    let cellID = "id"
    
    enum Cell: Int {
        case between = 0
        case tts
        case darkMode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonsTable = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
        buttonsTable.register(SettinsTableViewCell.self, forCellReuseIdentifier: cellID)
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cell.darkMode.rawValue + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellType = Cell.init(rawValue: indexPath.row) else { return UITableViewCell() }
        switch cellType {
        case .between,.tts:
            if let cell = buttonsTable.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SettinsTableViewCell {
                let pause: Pause = cellType == .tts ? .tts : .betweenPhrases
                cell.textLabel?.text = pause.rawValue
                cell.configure(pause: pause)
                cell.isHighlighted = false
                cell.selectionStyle = .none
                cell.tag = indexPath.item
                return cell
            }
            return UITableViewCell()
        case .darkMode:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            cell.textLabel?.text = "Light Mode"
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(RecordService.shared.isLightModeOn, animated: true)
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            return cell
        }
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        RecordService.shared.isLightModeOn = sender.isOn
    }
    
}
