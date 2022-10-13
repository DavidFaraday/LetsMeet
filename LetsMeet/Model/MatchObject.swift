//
//  MatchObject.swift
//  LetsMeet
//
//  Created by David Kababyan on 16/07/2020.
//

import Foundation


struct MatchObject {
    
    let id: String
    let memberIds: [String]
    let date: Date
    
    var dictionary: [String : Any] {
        return [kID : id, kMEMBERIDS : memberIds, kDATE : date]
    }
    
    func saveToFireStore() {
        
        FirebaseReference(.Match).document(self.id).setData(self.dictionary)
    }
}
