//
//  FCollectionReference.swift
//  LetsMeet
//
//  Created by David Kababyan on 30/06/2020.
//

import Foundation
import FirebaseFirestore


enum FCollectionReference: String {
    case User
    case Like
    case Match
    case Recent
    case Messages
    case Typing
}


func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    
    return Firestore.firestore().collection(collectionReference.rawValue)
}
