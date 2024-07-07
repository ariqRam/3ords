//
//  DictRecord.swift
//  ThreeWords
//
//  Created by Ariq Ramdhany on 05/07/24.
//

import Foundation

struct DictRecord: Identifiable {
    var id = UUID()
    var word: String
    var reading: String
    var altReading: String
    var meaning: String
}

extension DictRecord {
    static let sampleData: [DictRecord] = [
        DictRecord(word: "私", reading: "わたし", altReading: "わたくし", meaning: "I, me, I (polite)"),
        DictRecord(word: "人", reading: "ひと", altReading: "にん、じん", meaning: "person, human"),
        DictRecord(word: "日", reading: "ひ", altReading: "にち、じつ", meaning: "day, sun"),
        DictRecord(word: "月", reading: "つき", altReading: "げつ、がつ", meaning: "moon, month"),
        DictRecord(word: "火", reading: "ひ", altReading: "か", meaning: "fire"),
        DictRecord(word: "水", reading: "みず", altReading: "すい", meaning: "water"),
        DictRecord(word: "木", reading: "き", altReading: "もく、ぼく", meaning: "tree, wood"),
        DictRecord(word: "金", reading: "かね", altReading: "きん、こん", meaning: "gold, money"),
        DictRecord(word: "土", reading: "つち", altReading: "ど、と", meaning: "earth, soil"),
        DictRecord(word: "空", reading: "そら", altReading: "くう", meaning: "sky, empty"),
        DictRecord(word: "山", reading: "やま", altReading: "さん、ざん", meaning: "mountain"),
        DictRecord(word: "川", reading: "かわ", altReading: "せん", meaning: "river"),
        DictRecord(word: "田", reading: "た", altReading: "でん", meaning: "rice field"),
        DictRecord(word: "雨", reading: "あめ", altReading: "う", meaning: "rain"),
        DictRecord(word: "花", reading: "はな", altReading: "か", meaning: "flower"),
        DictRecord(word: "魚", reading: "さかな", altReading: "ぎょ", meaning: "fish"),
    ]
}

class CSVLoader {
    static func loadCSV(from filename: String) -> [DictRecord] {
        guard let filePath = Bundle.main.path(forResource: filename, ofType: "csv") else {
            print("CSV file not found")
            return []
        }
        
        do {
            let content = try String(contentsOfFile: filePath)
            var records: [DictRecord] = []
            let lines = content.components(separatedBy: "\n")
            
            // Assuming the first line is the header
            for (index, line ) in lines.enumerated() {
                if index == 0 { continue }
                
                let values = line.components(separatedBy: ";")
                if values.count == 4 {
                    print(records)
                    let record = DictRecord(word: values[0], reading: values[1], altReading: values[2], meaning: values[3])
                    records.append(record)
                }
            }
            return records
            
        } catch {
            print("Error reading CSV file: \(error)")
            return []
        }
    }
}
