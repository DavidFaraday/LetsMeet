//
//  FUser.swift
//  LetsMeet
//
//  Created by David Kababyan on 28/06/2020.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import UIKit

enum Gender: String, Codable, CaseIterable {
    case Lesbian, Gay, Bi, Trans
}

class FUser: Equatable {
    
    let id: String
    var email: String
    var username: String
    var dateOfBirth: Date
    var profession: String
    var jobTitle: String
    var about: String
    var city: String
    var country: String
    var height: Double
    var lookingFor: String
    var avatarLink: String
    
    var likedIdArray: [String]?
    var imageLinks: [String]?
    let registeredDate = Date()
    var pushId: String?
    var age: Int
    var gender: String
    
    var avatar: UIImage?

    static func == (lhs: FUser, rhs: FUser) -> Bool {
        lhs.id == rhs.id
    }

    

    
    var userDictionary: NSDictionary {
        
        return NSDictionary(objects: [
                                    self.id,
                                    self.email,
                                    self.username,
                                    self.dateOfBirth,
                                    self.profession,
                                    self.jobTitle,
                                    self.about,
                                    self.city,
                                    self.country,
                                    self.height,
                                    self.lookingFor,
                                    self.avatarLink,
                                    self.likedIdArray ?? [],
                                    self.imageLinks ?? [],
                                    self.registeredDate,
                                    self.pushId ?? "",
                                    self.age,
                                    self.gender
            ],
            
            forKeys: [kID as NSCopying,
                      kEMAIL as NSCopying,
                      kUSERNAME as NSCopying,
                      kDATEOFBIRTH as NSCopying,
                      kPROFESSION as NSCopying,
                      kJOBTITLE as NSCopying,
                      kABOUT as NSCopying,
                      kCITY as NSCopying,
                      kCOUNTRY as NSCopying,
                      kHEIGHT as NSCopying,
                      kLOOKINGFOR as NSCopying,
                      kAVATARLINK as NSCopying,
                      kLIKEDIDARRAY as NSCopying,
                      kIMAGELINKS as NSCopying,
                      kREGISTEREDDATE as NSCopying,
                      kPUSHID as NSCopying,
                      kAGE as NSCopying,
                      kGENDER as NSCopying
                ])
        
    }
    
    //MARK: - Inits
    
    init(_id: String, _email: String, _username: String, _city: String, _dateOfBirth: Date, _avatarLink: String = "", _gender: String) {
        
        id = _id
        email = _email
        username = _username
        dateOfBirth = _dateOfBirth
        profession = ""
        jobTitle = ""
        about = ""
        city = _city
        country = ""
        height = 0.0
        lookingFor = ""
        avatarLink = _avatarLink
        likedIdArray = []
        imageLinks = []
        age = abs(dateOfBirth.interval(ofComponent: .year, fromDate: Date()))
        gender = _gender
    }
    
    
    init(_dictionary: NSDictionary) {
        
        id = _dictionary[kID] as? String ?? ""
        email = _dictionary[kEMAIL] as? String ?? ""
        username = _dictionary[kUSERNAME] as? String ?? ""
        profession = _dictionary[kPROFESSION] as? String ?? ""
        jobTitle = _dictionary[kJOBTITLE] as? String ?? ""
        about = _dictionary[kABOUT] as? String ?? ""
        city = _dictionary[kCITY] as? String ?? ""
        country = _dictionary[kCOUNTRY] as? String ?? ""
        height = _dictionary[kHEIGHT] as? Double ?? 0.0
        lookingFor = _dictionary[kLOOKINGFOR] as? String ?? ""
        avatarLink = _dictionary[kAVATARLINK] as? String ?? ""
        likedIdArray = _dictionary[kLIKEDIDARRAY] as? [String]
        imageLinks = _dictionary[kIMAGELINKS] as? [String]
        pushId = _dictionary[kPUSHID] as? String ?? ""
        
        age = _dictionary[kAGE] as? Int ?? 18
        gender = _dictionary[kGENDER] as? String ?? Gender.Gay.rawValue

        
        if let date = _dictionary[kDATEOFBIRTH] as? Timestamp {
            dateOfBirth = date.dateValue()
        } else {
            dateOfBirth = _dictionary[kDATEOFBIRTH] as? Date ?? Date()
        }
                
        avatar = UIImage(contentsOfFile: fileInDocumentsDirectory(filename: self.id)) ?? UIImage(named: "mPlaceholder")
    }

    //MARK: - Returning current user
    
    static func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    static func currentUser() -> FUser? {
        
        if Auth.auth().currentUser != nil {
            if let userDictionary = userDefaults.object(forKey: kCURRENTUSER) {
                return FUser(_dictionary: userDictionary as! NSDictionary)
            }
        }
        
        return nil
    }

    func getUserAvatarFromFirestore(completion: @escaping (_ didSet: Bool) -> Void) {
        
        FileStorage.downloadImage(imageUrl: self.avatarLink) { (avatarImage) in
            
            self.avatar = avatarImage ?? UIImage(named: "mPlaceholder")
            
            completion(true)
        }
    }
}
    
    
    
    
    
    



func createUsers() {
    
    let names = ["Alison Stamp", "Inayah Duggan", "Alfie-Lee Thornton", "Rachelle Neale", "Anya Gates", "Juanita Bate"]
    
    var imageIndex = 1
    var userIndex = 1
    
    for i in 0..<names.count {
        let gender = Gender.allCases[Int.random(in: 0...3)].rawValue

        let id = UUID().uuidString
        
        let fileDirectory = "Avatars/_" + id + ".jpg"

        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { (avatarLink) in
            
            let user = FUser(_id: id, _email: "user\(userIndex)@mail.com", _username: names[i], _city: "No City", _dateOfBirth: Date().date(with: 1995, month: 11, day: 12), _avatarLink: avatarLink ?? "", _gender: gender)
            
            userIndex += 1
            FirebaseUserListener.shared.saveUserToFireStore(user)
        }
        
        imageIndex += 1
        
        if imageIndex == 16 {
            imageIndex = 1
        }
        
    }
}
