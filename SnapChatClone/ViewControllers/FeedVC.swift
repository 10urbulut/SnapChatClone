//
//  FeedVC.swift
//  SnapChatClone
//
//  Created by Onur Bulut on 20.09.2023.
//

import UIKit
import Firebase
import SDWebImage

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

   
    
    let fireStoreDatabase = Firestore.firestore()
    var snapArray = [Snap]()
    var chosenSnap : Snap?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getUserInfo()
        getSnapsFromFirebase()
        print("FEEEEd")
        
    }
    
    func getSnapsFromFirebase(){
        fireStoreDatabase.collection("Snaps").order(by: "date", descending: true).addSnapshotListener { snapShot, error in
            if error != nil{
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "")
                return
            }
            
            if snapShot?.isEmpty == false && snapShot != nil{
                self.snapArray.removeAll()
                for document in snapShot!.documents{
                    
                    if let userName = document.get("snapOwner") as? String{
                        if let imageUrlArray = document.get("imageUrlArray") as? [String]{
                            if let date = document.get("date") as? Timestamp{
                                
                                if let difference = Calendar.current.dateComponents([.hour], from: date.dateValue(), to: Date()).hour{
                                    if difference >= 24{
                                        self.fireStoreDatabase.collection("Snaps").document(document.documentID).delete { error in
                                            if error != nil {
                                                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Silinemdi")
                                            }
                                        }
                                        
                                    }
                                    
                                    let snap = Snap(userName: userName, imageUrlArray: imageUrlArray, date: date.dateValue(), timeDifference: 24 - difference)
                                    
                                    self.snapArray.append(snap)
                                    
                                }
                                
                            
                            }
                        }
                        
                        
                        
                    }
                }
                self.tableView.reloadData()
                
            }
        }
    }
        
    

    func getUserInfo()  {
        fireStoreDatabase.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser?.email ?? "").getDocuments { query, error in
            
            if error != nil{
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            return
                
            }
            
            if query?.isEmpty == false && query != nil{
                
                for document in query!.documents{
                    
                    if let userName = document.get("userName") as? String{
                        UserSingleton.sharedUserInfo.email = Auth.auth().currentUser?.email ?? ""
                        UserSingleton.sharedUserInfo.userName = userName
                        
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
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell" , for: indexPath) as! FeedCell
        cell.feedUserNameLabel.text = snapArray[indexPath.row].userName
        
        if snapArray[indexPath.row].imageUrlArray.isEmpty == false {
            cell.feedImageView.sd_setImage(with: URL(string: snapArray[indexPath.row].imageUrlArray[0]))

        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapArray.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSnapVC"{
            let destinationVC = segue.destination as! SnapVC
            
            destinationVC.selectedSnap = chosenSnap
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenSnap = self.snapArray[indexPath.row]
        performSegue(withIdentifier: "toSnapVC", sender: nil)
    }
}
