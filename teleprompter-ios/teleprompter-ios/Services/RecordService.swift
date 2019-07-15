//
//  RecordService
//  teleprompter-ios
//
//  https://sispo.co
//  Created for Robert Savage, Pronunciator, LLC
//  Copyright © 2018 Sispo. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

class RecordService {
    
    static let shared = RecordService()
    
    var allRecords: [Record] = []
    var undoneRecords: [Record] {
        return allRecords.filter { !$0.isDone } .sorted(by: { $0.number < $1.number })
    }
    
    enum PlayMode {
        case standard
        case undone
        case all
    }
    
    var currentRecord: Record?
    var currentMode: PlayMode = .standard
    var hasPlayedOnce = false
    var shouldPlayNext = false
    
    var pauseTimeBetweenPhrases: TimeInterval {
        get {
            return defs.value(forKey: "pauseTimeBetweenPhrases") as? TimeInterval ?? 2.0
        }
        set {
            defs.set(newValue, forKey: "pauseTimeBetweenPhrases")
        }
    }
    
    var pauseTTS: TimeInterval {
        get {
            return defs.value(forKey: "pauseTTS") as? TimeInterval ?? 1.0
        }
        set {
            defs.set(newValue, forKey: "pauseTTS")
        }
    }
    
    var isLightModeOn: Bool {
        get {
            return defs.bool(forKey: "is-light-mode-on")
        }
        set {
            defs.set(newValue, forKey: "is-light-mode-on")
        }
    }
    
    var currentFontSize: CGFloat {
        get {
            return defs.value(forKey: "font-size") as? CGFloat ?? 32.0
        }
        set {
            if newValue > 9 {
                defs.set(newValue, forKey: "font-size")
            }
        }
    }
    
    func saveRecordsLocally() {
        var encodedData: [Data] = [Data]()
        for i in 0..<allRecords.count{
            if let encoded = try? JSONEncoder().encode(self.allRecords[i]){
                encodedData.append(encoded)
            }
        }
        defs.set(encodedData, forKey: "record_data")
    }
    
    func getLocalRecords() {
        var records: [Record] = [Record]()
        if let jsonData: [Data] = defs.array(forKey: "record_data") as? [Data] {
            for i in 0..<jsonData.count{
                if let data = try? JSONDecoder().decode(Record.self, from: jsonData[i]){
                    records.append(data)
                }
            }
        }
        allRecords = records
    }
    
    func selectNextRecord() {
        if let currentRecord = currentRecord {
            self.currentRecord = findNextBySerial(record: currentRecord, up: true)
        } else if currentMode == .standard {
            self.currentRecord = undoneRecords.first
        }
    }
    
    func selectPreviousRecord() {
        if let currentRecord = currentRecord {
            self.currentRecord = findNextBySerial(record: currentRecord, up: false)
        }
    }
    
    func findNextBySerial(record: Record, up: Bool) -> Record? {
        
        if up {
            
            switch currentMode {
            case .all:
                return findNextBySerialAll(record: record, up: up)
            case .standard, .undone:
                
                if let last = undoneRecords.last {
                    var offset = 1
                    
                    while offset + record.number <= last.number {
                        
                        if let record = undoneRecords.filter({ $0.number == record.number + offset }).first {
                            return record
                        }
                        offset += 1
                    }
                    
                    return last
                }
                
            }
            
            
        } else {
            return findNextBySerialAll(record: record, up: up)
        }
        
        return nil
    }
    
    func findNextBySerialAll(record: Record, up: Bool) -> Record? {
        if let recordIndex = allRecords.firstIndex(of: record) {
            if up {
                if recordIndex < allRecords.count - 1 {
                    return allRecords[recordIndex + 1]
                } else {
                    return allRecords.last
                }
            } else {
                if recordIndex > 0 {
                    return allRecords[recordIndex - 1]
                } else {
                    return allRecords.first
                }
            }
        }
        return nil
    }

    func getRecordsFrom(_ url: URL,
               completion: @escaping (Error?)->Void) {
        
        Alamofire.request(url, method: .get).responseData { response in
            switch response.result {
            case .success(let value):
                guard let string = String(data: value, encoding: .utf8) else { return }
                
                let arr = string.components(separatedBy: "\r\n")
                var responses : [[String]] = [[String]]()
                for i in 0..<arr.count{
                    responses.append([])
                    responses[i] = arr[i].components(separatedBy: "\t")
                }
                
                var records = [Record]()
                
                for i in 0..<responses.count {
                    
                    let responceArray = responses[i]
                    
                    if responceArray.count == 4 {
                        let idString = responceArray[0]
                        let isDone = responceArray[1] == "1"
                        let text = responceArray[2]
                        let audioURLString = responceArray[3]
                        
                        guard let id = Int(idString),
                            let audioURL = URL.init(string: audioURLString) else {
                                continue
                        }
                        
                        let record = Record.init(number: id, isDone: isDone, text: text, musicUrl: audioURL)
                        records.append(record)
                    }
                }
                self.allRecords = records
                self.saveRecordsLocally()
                completion(nil)
                
            case .failure(let error):
                completion(error)
            }
        }
    }

}
