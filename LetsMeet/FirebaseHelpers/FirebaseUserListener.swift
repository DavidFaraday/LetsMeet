//
//  FirebaseUserListener.swift
//  LetsMeet
//
//  Created by David Kababyan on 07/06/2022.
//

import Foundation
import Firebase

class FirebaseUserListener {
    
    static let shared = FirebaseUserListener()
    
    private init() { }

    
    //MARK: - Login
    func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            
            
            if error == nil {
                
                if authDataResult!.user.isEmailVerified {
                    
                    FirebaseUserListener.shared.downloadCurrentUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                    completion(error, true)
                    
                } else {
                    print("Email not verified")
                    completion(error, false)
                }
                
            } else {
                completion(error, false)
            }
        }
    }
    
    //MARK: - Register

    func registerUserWith(email: String, password: String, userName: String, city: String, dateOfBirth: Date, gender: String, completion: @escaping (_ error: Error?) -> Void) {
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (authData, error) in
                        
            completion(error)
            
            if error == nil {
                
                authData?.user.sendEmailVerification(completion: { (error) in

                    completion(error)
                })
                
                if authData?.user != nil {
                    let user = FUser(_id: authData!.user.uid, _email: email, _username: userName, _city: city, _dateOfBirth: dateOfBirth, _gender: gender)
                    
                    self.saveUserLocally(user)
                }
            }
        }
    }

    //MARK: - Update User funcs
    
    func updateCurrentUserInFireStore(withValues: [String : Any], completion: @escaping (_ error: Error?) -> Void) {
        
        if let dictionary = userDefaults.object(forKey: kCURRENTUSER) {
            
            let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
            userObject.setValuesForKeys(withValues)
            
            FirebaseReference(.User).document(FUser.currentId()).updateData(withValues) {
                error in
                
                completion(error)
                if error == nil {
                    self.saveUserLocally(FUser(_dictionary: userObject))
                }
            }
        }
    }
    

    //MARK: - Resend Links
    func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().currentUser?.reload(completion: { (error) in
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                
                completion(error)
            })
        })
    }
    
    func resetPassword(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    //MARK: - Edit User profile
    
    func updateUserEmail(newEmail: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().currentUser?.updateEmail(to: newEmail, completion: { (error) in
            
            FirebaseUserListener.shared.resendVerificationEmail(email: newEmail) { (error) in

            }
            completion(error)
        })
    }
    

    //MARK: - LogOut user
    
    func logOutCurrentUser(completion: @escaping(_ error: Error?) ->Void) {
        
        do {
            try Auth.auth().signOut()
            
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)

        } catch let error as NSError {
            completion(error)
        }
    }


    //MARK: - Download
    func downloadCurrentUserFromFirebase(userId: String, email: String) {
        
        FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
            print("downloading user")
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {

                let user = FUser(_dictionary: snapshot.data() as! NSDictionary)
                self.saveUserLocally(user)
                
                user.getUserAvatarFromFirestore { (didSet) in
                    
                }
                
            } else {
                //first login
                print("first login")
                if let user = userDefaults.object(forKey: kCURRENTUSER) {
                    self.saveUserToFireStore(FUser(_dictionary: user as! NSDictionary))
                }
                
            }
        }
    }

    //MARK: - Save user funcs
    func saveUserLocally(_ user: FUser) {

        userDefaults.setValue(user.userDictionary as! [String : Any], forKey: kCURRENTUSER)
        userDefaults.synchronize()
    }
    
    func saveUserToFireStore(_ user: FUser) {

        FirebaseReference(.User).document(user.id).setData(user.userDictionary as! [String : Any]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}
