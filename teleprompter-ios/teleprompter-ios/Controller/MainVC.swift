//
//  MainVC
//  teleprompter-ios
//
//  https://sispo.co
//  Created for Robert Savage, Pronunciator, LLC
//  Copyright © 2018 Sispo. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import AirTurnInterface

class MainVC: UIViewController {
    
    let rs = RecordService.shared
    
    var shouldWaitPauseBetweenPhrases = false
    
    var audioPlayer: AVAudioPlayer?
    
    var synthesizer = AVSpeechSynthesizer()
    
    var request: DownloadRequest?

    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let barButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "FontAwesome5ProSolid", size: 20.0)
        button.setTitle("bars", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        return button
    }()
    
    let forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "FontAwesome5ProSolid", size: 20.0)
        button.setTitle("forward", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(goNext), for: .touchUpInside)
        return button
    }()
    
    let backwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "FontAwesome5ProSolid", size: 20.0)
        button.setTitle("backward", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return button
    }()
    
    let manualModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "FontAwesome5ProSolid", size: 20.0)
        button.setTitle("", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(changeManualMode), for: .touchUpInside)
        return button
    }()
    
    let flipVerticalButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "FontAwesome5ProSolid", size: 20.0)
        button.setTitle("", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(flipVertically), for: .touchUpInside)
        return button
    }()
    
    let flipHorizontalButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "FontAwesome5ProSolid", size: 20.0)
        button.setTitle("", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(flipHorizontally), for: .touchUpInside)
        return button
    }()
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "FontAwesome5ProSolid", size: 20.0)
        button.setTitle("play", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        return button
    }()
    
    let increaseTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "FontAwesome5ProSolid", size: 20.0)
        button.setTitle("plus", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        return button
    }()
    
    let decreaseTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "FontAwesome5ProSolid", size: 20.0)
        button.setTitle("minus", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAirTurn()
        view.backgroundColor = .white
        
        prepareForConstraints(label)
        prepareForConstraints(barButton)
        prepareForConstraints(forwardButton)
        prepareForConstraints(backwardButton)
        prepareForConstraints(playButton)
        prepareForConstraints(manualModeButton)
        prepareForConstraints(flipVerticalButton)
        prepareForConstraints(flipHorizontalButton)
        prepareForConstraints(increaseTextButton)
        prepareForConstraints(decreaseTextButton)
        
        updateLabelPointSize()
        
        let constrains = [
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -120),
            
            barButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            barButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            barButton.heightAnchor.constraint(equalToConstant: 50),
            barButton.widthAnchor.constraint(equalToConstant: 50),
            
            backwardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -190),
            backwardButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            backwardButton.heightAnchor.constraint(equalToConstant: 50),
            backwardButton.widthAnchor.constraint(equalToConstant: 50),
            
            forwardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            forwardButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            forwardButton.heightAnchor.constraint(equalToConstant: 50),
            forwardButton.widthAnchor.constraint(equalToConstant: 50),
            
            playButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            playButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            
            manualModeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -330),
            manualModeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            manualModeButton.heightAnchor.constraint(equalToConstant: 50),
            manualModeButton.widthAnchor.constraint(equalToConstant: 50),
            
            flipVerticalButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -260),
            flipVerticalButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            flipVerticalButton.heightAnchor.constraint(equalToConstant: 50),
            flipVerticalButton.widthAnchor.constraint(equalToConstant: 50),
            
            flipHorizontalButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -190),
            flipHorizontalButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            flipHorizontalButton.heightAnchor.constraint(equalToConstant: 50),
            flipHorizontalButton.widthAnchor.constraint(equalToConstant: 50),
            
            increaseTextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            increaseTextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            increaseTextButton.heightAnchor.constraint(equalToConstant: 50),
            increaseTextButton.widthAnchor.constraint(equalToConstant: 50),
            
            decreaseTextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            decreaseTextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            decreaseTextButton.heightAnchor.constraint(equalToConstant: 50),
            decreaseTextButton.widthAnchor.constraint(equalToConstant: 50),
        ]
        NSLayoutConstraint.activate(constrains)
    }
    
    func prepareForConstraints(_ view: UIView) {
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func updateUIMode() {
        view.backgroundColor = rs.isLightModeOn ? .white : #colorLiteral(red: 0.0509704873, green: 0.050987266, blue: 0.05096828192, alpha: 1)
        label.textColor = rs.isLightModeOn ? .darkGray : .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIMode()
        if rs.shouldPlayNext {
            rs.shouldPlayNext = false
            shouldWaitPauseBetweenPhrases = false
            playTapped()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playButton.setTitle("play", for: .normal)
        invalidate()
        rs.currentRecord = nil
        label.text = ""
    }
    
    func updateLabelPointSize() {
        label.font = label.font.withSize(rs.currentFontSize)
    }
    
    func setupAirTurn() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AirTurnPedalPress, object: nil, queue: nil) { (notification) -> Void in
            if let dict = notification.userInfo as? [String:AnyObject], let portNum = dict[AirTurnPortNumberKey] as? NSNumber, let pedal = Pedal.init(rawValue: portNum.intValue) {
                print("Pedal \(pedal.rawValue)")
                self.handleTap(pedal: pedal)
            }
        }
    }
    
    let DELAY: TimeInterval = 1
    
    var numberOfTaps = 0
    var currentPedal: Pedal? = nil
    
    enum Pedal: Int {
        case left = 1
        case right = 3
    }
    
    var tapTimer: Timer?
    
    func handleTap(pedal: Pedal) {
        
        if let current = currentPedal {
            if current != pedal {
                self.numberOfTaps = 0
                self.tapTimer = nil
            }
        }
        
        currentPedal = pedal
        numberOfTaps += 1
        
        guard let _ = tapTimer else {
            tapTimer = Timer.scheduledTimer(withTimeInterval: DELAY, repeats: false, block: { (timer) in
                guard let pedal = self.currentPedal else { return }
                switch pedal {
                case .left:
                    if self.numberOfTaps > 1 {
                        //Back twice
                        self.goBack()
                        self.goBack()
                    } else {
                        //Back
                        self.goBack()
                    }
                case .right:
                    if self.numberOfTaps > 1 {
                        //Pause
                        self.invalidate()
                    } else {
                        //Next or Play
                        self.goNext()
                    }
                }
                self.numberOfTaps = 0
                self.tapTimer = nil
            })
            return
        }
    }
    
    var isManualModeEnabled = false
    
    @objc func changeManualMode() {
        manualModeButton.backgroundColor = isManualModeEnabled ? #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0.2974410599, blue: 0.5043075771, alpha: 1)
        isManualModeEnabled = !isManualModeEnabled
    }
    
    var isFlippedVertically = false
    var isFlippedHorizontally = false
    
    @objc func flipVertically() {
        flipVerticalButton.backgroundColor = isFlippedVertically ? #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0.2974410599, blue: 0.5043075771, alpha: 1)
        isFlippedVertically = !isFlippedVertically
        flipLabel()
    }
    
    @objc func flipHorizontally() {
        flipHorizontalButton.backgroundColor = isFlippedHorizontally ? #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0.2974410599, blue: 0.5043075771, alpha: 1)
        isFlippedHorizontally = !isFlippedHorizontally
        flipLabel()
    }
    
    func flipLabel() {
        let transformX: CGFloat = isFlippedVertically ? -1 : 1
        let transformY: CGFloat = isFlippedHorizontally ? -1 : 1
        label.transform = CGAffineTransform(scaleX: transformX, y: transformY)
    }
    
    @objc func goBack() {
        shouldWaitPauseBetweenPhrases = false
        rs.selectPreviousRecord()
        play()
    }
    
    @objc func goNext() {
        shouldWaitPauseBetweenPhrases = false
        rs.selectNextRecord()
        play()
    }
    
    @objc func zoomIn() {
        rs.currentFontSize *= 1.2
        updateLabelPointSize()
    }
    
    @objc func zoomOut() {
        rs.currentFontSize *= 0.8
        updateLabelPointSize()
    }
    
    @objc func playTapped() {
        
        if playButton.currentTitle == "play" {
            if rs.currentRecord == nil {
                rs.currentMode = .standard
                rs.selectNextRecord()
            }
            playButton.setTitle("pause", for: .normal)
            play()
        } else {
            playButton.setTitle("play", for: .normal)
            invalidate()
        }
    }
    
    enum Stage {
        case betweenPhrases
        case serialNumber
        case tts
        case audio
        case none
    }
    
    var currentStage: Stage = .none
    
    var timerBetweenPhrases: Timer?
    var timerTTS: Timer?
    
    func play() {
        invalidate()
        guard let _ = rs.currentRecord else {
            playButton.setTitle("play", for: .normal)
            if rs.currentMode != .standard {
                if rs.hasPlayedOnce {
                    rs.currentMode = .standard
                    rs.saveRecordsLocally()
                    self.showAlert(title: "Done", message: "End Reached")
                }
            } else {
                if rs.hasPlayedOnce {
                    rs.saveRecordsLocally()
                    self.showAlert(title: "Done", message: "End of Input File Reached")
                }
            }
            return
        }
        currentStage = .betweenPhrases
        if isManualModeEnabled || !shouldWaitPauseBetweenPhrases {
            self.finishPauseBetweenPhrases()
        } else {
            timerBetweenPhrases = Timer.scheduledTimer(withTimeInterval: TimeInterval(rs.pauseTimeBetweenPhrases), repeats: false, block: { (timer) in
                self.finishPauseBetweenPhrases()
            })
        }
    }
    
    func finishPauseBetweenPhrases() {
        print("Finished btf")
        guard let currentRecord = rs.currentRecord else { return }
        self.currentStage = .serialNumber
        self.label.text = ""
        self.playSerialNumber(for: currentRecord)
    }
    
    func invalidate() {
        timerBetweenPhrases?.invalidate()
        timerBetweenPhrases = nil
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        timerTTS?.invalidate()
        timerTTS = nil
        request?.cancel()
        request = nil
        audioPlayer?.delegate = nil
        audioPlayer?.stop()
        audioPlayer = nil
        currentStage = .none
    }
    
    func onFinishSerialNumberPlay() {
        guard let currentRecord = rs.currentRecord else { return }
        currentStage = .tts
        timerTTS = Timer.scheduledTimer(withTimeInterval: TimeInterval(rs.pauseTTS), repeats: false, block: { (timer) in
            print("Finished tts")
            self.currentStage = .audio
            self.label.text = currentRecord.text
            self.request = self.getSound(currentRecord.musicUrl, completion: { (url, error) in
                guard let audioURL = url else {
                    guard error?.code == -999 else {
                        self.showAlert(title: "Error", message: "Failed to download the record's audio file") {
                            self.play()
                        }
                        return
                    }
                    return
                }
                self.playSound(from: audioURL)
            })
        })
    }
    
    
    func getSound(_ url: URL, completion: @escaping (URL?, NSError?)->()) -> DownloadRequest {
        let destination: DownloadRequest.DownloadFileDestination = { _, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename ?? "")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        return Alamofire.download(
            url,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil,
            to: destination).downloadProgress(closure: { (progress) in
                //progress closure
            }).response(completionHandler: { (response) in
                //here you able to access the DefaultDownloadResponse
                //result closure
                completion(response.destinationURL, response.error as NSError?)
            })
    }
    
    func playSerialNumber(for record: Record) {
        let utterance = AVSpeechUtterance(string: stringFor(serial: record.number))
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    func stringFor(serial: Int) -> String {
        var string = ""
        serial.array.forEach { (digit) in
            string.append(digit + " ")
        }
        return string
    }
    
    func playSound(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
    }
    
    @objc func openMenu(){
        let splitVC = SplitVC()
        show(splitVC, sender: self)
    }
}

extension MainVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            shouldWaitPauseBetweenPhrases = true
            rs.hasPlayedOnce = true
            rs.currentRecord?.isDone = true
            if !isManualModeEnabled {
                rs.selectNextRecord()
                play()
            }
        } else {
            self.showAlert(title: "Error", message: "Failed to play the record's text") {
                self.play()
            }
        }
    }
}

extension MainVC: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Finished utt")
        onFinishSerialNumberPlay()
    }
    
}

extension UIViewController {
    func showAlert(title: String, message: String, completion: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: .cancel, handler: { (action) in
            completion?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
