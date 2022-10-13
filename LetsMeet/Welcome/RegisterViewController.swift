//
//  RegisterViewController.swift
//  LetsMeet
//
//  Created by David Kababyan on 27/06/2020.
//

import UIKit
import ProgressHUD

class RegisterViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var passwordTextFiled: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    //MARK: - Vars
    var isMale = true
    let genderPickerView = UIPickerView()
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .dark
        setupBackgroundTouch()
        setupGenderPickerView()
    }
    

    //MARK: - IBActions
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        if isTextDataImputed() {
            
            if passwordTextFiled.text! == confirmPasswordTextField.text! {
                registerUser()
            } else {
                ProgressHUD.showError("Passwords don't match!")
            }
            
        } else {
            ProgressHUD.showError("All fields are required!")
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: - Setup
    
    private func setupGenderPickerView() {
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        
        genderTextField.inputView = genderPickerView
    }
    
    
    private func setupBackgroundTouch() {
        backgroundImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        backgroundImageView.addGestureRecognizer(tapGesture)
    }

    @objc func backgroundTap() {
        dismissKeyboard()
    }

    //MARK: - Helpers
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }

        
    private func isTextDataImputed() -> Bool {
        
        return usernameTextField.text != "" && emailTextField.text != "" && cityTextField.text != "" && passwordTextFiled.text != "" && confirmPasswordTextField.text != "" && genderTextField.text != ""
    }
    
    //MARK: - RegisterUser
    private func registerUser() {

        ProgressHUD.show()

        FirebaseUserListener.shared.registerUserWith(email: emailTextField.text!, password: passwordTextFiled.text!, userName: usernameTextField.text!, city: cityTextField.text!, dateOfBirth: datePicker.date, gender: genderTextField.text!, completion:  {
            error in

            if error == nil {
                ProgressHUD.showSuccess("Verification email sent!")
                self.dismiss(animated: true, completion: nil)
            } else {
                ProgressHUD.showError(error!.localizedDescription)
            }

        })
    }
}


extension RegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Gender.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Gender.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = Gender.allCases[row].rawValue
    }
    
}
