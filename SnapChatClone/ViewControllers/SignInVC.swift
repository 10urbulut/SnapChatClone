//
//  ViewController.swift
//  SnapChatClone
//
//  Created by Onur Bulut on 20.09.2023.
//

import UIKit
import Firebase

class SignInVC: UIViewController {

    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var userNameText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    
    @IBAction func signInClicked(_ sender: Any) {
        if  passwordText.text == "" && emailText.text == ""{
            self.makeAlert(title: "Error", message: "Username/Password/Email ?")
            return
        }
        
        Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { auth, error in
            if error != nil{
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                return
            }
        }
        
        self.performSegue(withIdentifier: "toFeedVC", sender: nil)
        
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        if userNameText.text == "" && passwordText.text == "" && emailText.text == ""{
            self.makeAlert(title: "Error", message: "Username/Password/Email ?")
            return
        }
        Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { auth, error in
            if error != nil{
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                return
            }
            
            let fireStore = Firestore.firestore()
            let userDictionary = ["email": self.emailText.text!,"userName": self.userNameText.text! ] as [String : Any]
            
            fireStore.collection("UserInfo").addDocument(data: userDictionary) { error in
                if error != nil {
                    self.makeAlert(title: "Error", message: error!.localizedDescription)
                return
                    
                }
            }
            
            
            self.performSegue(withIdentifier: "toFeedVC", sender: nil)
            
        }
        
        
    }
    
    
    func makeAlert(title: String , message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}

