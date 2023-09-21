//
//  UploadVC.swift
//  SnapChatClone
//
//  Created by Onur Bulut on 20.09.2023.
//

import UIKit
import Firebase

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var uploadImageView: UIImageView!
    

    override func viewDidLoad() {

        uploadImageView.isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePicture))

        uploadImageView.addGestureRecognizer(gestureRecognizer)
        super.viewDidLoad()
        
    }
    
    @objc func choosePicture(){
        
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        uploadImageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }

    @IBAction func uploadButtonClicked(_ sender: Any) {
        
     
        
        // Storage
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference
            .child("media")
        
        
        if let data = uploadImageView.image?.jpegData(compressionQuality: 0.5){
            let uuid = UUID().uuidString
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data) { metaData, error in
                if error != nil {
                    self.makeAlert(title: "Error", message: error!.localizedDescription)
                    return
                    
                }
                
                
                imageReference.downloadURL { url, error in
                    if error == nil{
                        let imageUrl = url?.absoluteString
                        
                        
                        // Firestore
                        
                        let fireStore = Firestore.firestore()
                        
                        fireStore.collection("Snaps").whereField("snapOwner", isEqualTo: UserSingleton.sharedUserInfo.userName).getDocuments { query, error in
                            if error != nil {
                                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "")
                                return
                            }
                            
                            if query?.isEmpty == false && query != nil {
                                for document in query!.documents{
                                    let documentId = document.documentID
                                  if  var  imageUrlArray = document.get("imageUrlArray") as? [String]{
                                      imageUrlArray.append(imageUrl!)
                                        
                                        
                                      let additionalDictionary = ["imageUrlArray":imageUrlArray] as [String:Any]
                                      
                                      fireStore.collection("Snaps").document(documentId).setData(additionalDictionary, merge: true) { error in
                                          
                                          if error != nil {
                                              self.makeAlert(title: "Error", message: error?.localizedDescription ?? "")
                                              return
                                          }
                                          self.tabBarController?.selectedIndex = 0
                                          self.uploadImageView.image = UIImage(named: "add_image.png")
                                          return
                                          
                                          
                                      }
                                    }
                                }
                                
                                return
                            }
                            
                            
                            let snapDictionary = ["imageUrlArray":[imageUrl!],"snapOwner":UserSingleton.sharedUserInfo.userName,"date":FieldValue.serverTimestamp()] as [String:Any]
                            fireStore.collection("Snaps").addDocument(data: snapDictionary) { error in
                                if error != nil {
                                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "")
                                    return
                                }
                                
                                self.tabBarController?.selectedIndex = 0
                                self.uploadImageView.image = UIImage(named: "add_image.png")
                            
                            
                        }
                        
                        
                   
                        }
                    }
                }
            }
        }
    }
    
    
    func makeAlert(title: String , message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
}
