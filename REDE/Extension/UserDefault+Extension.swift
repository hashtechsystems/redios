//
//  UserDefault+Extension.swift
//  REDE
//
//  Created by Avishek on 27/07/22.
//

import Foundation

extension UserDefaults{
    
    func setLoggedInToken(value: String?) {
        set(value, forKey: UserDefaultsKeys.loggedInToken.rawValue)
        synchronize()
    }
    
    func loggedInToken()-> String? {
        return string(forKey: UserDefaultsKeys.loggedInToken.rawValue)
    }
    
    func clearLoggedInToken(){
        removeObject(forKey: UserDefaultsKeys.loggedInToken.rawValue)
        synchronize()
    }
    
    func setActiveVisit(value: Bool) {
        set(value, forKey: UserDefaultsKeys.activeVisit.rawValue)
        synchronize()
    }
    
    func getActiveVisit()-> Bool {
        return bool(forKey: UserDefaultsKeys.activeVisit.rawValue)
    }
    
    func clearActiveVisit(){
        removeObject(forKey: UserDefaultsKeys.activeVisit.rawValue)
        synchronize()
    }
    
    func setUser(value: User?) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(value)
        set(data, forKey: UserDefaultsKeys.user.rawValue)
        synchronize()
    }
    
    func getUser()-> User? {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.user.rawValue) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(User.self, from: data)
    }
    
    func clearUser(){
        removeObject(forKey: UserDefaultsKeys.user.rawValue)
        synchronize()
    }
    
    func clearAll(){
        clearUser()
        clearActiveVisit()
        clearLoggedInToken()
    }
}

enum UserDefaultsKeys : String {
    case activeVisit
    case loggedInToken
    case user
}
