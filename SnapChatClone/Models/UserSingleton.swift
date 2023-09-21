//
//  UserSingleton.swift
//  SnapChatClone
//
//  Created by Onur Bulut on 20.09.2023.
//

import Foundation

class UserSingleton{
    static let sharedUserInfo = UserSingleton()
    
    var email = ""
    var userName = ""
    
    
    
    private init(){
        
    }
}
