//
//  ProfileUpdateDelegate.swift
//  Assignmen2
//
//  Created by kakim nyssanov on 20.02.2025.
//

import SwiftUI

protocol ProfileUpdateDelegate: AnyObject {
    func profileDidUpdate(_ profile: UserProfile)
    func profileLoadingError(_ error: Error)
}

private var userList = [UserProfile(id: UUID(), username: "Username", avatarURL: "https://avatars.githubusercontent.com/u/84794256?v=4", bio: "BIOfsdfkjdshfdsjf", followers: 0),]

class ProfileManager: ObservableObject{
    @Published var activeProfile: UserProfile?
    @Published var errorText: String?
    
    private var activeProfiles: [UUID: UserProfile] = [userList[0].id: userList[0]]
    
    weak var delegate: ProfileUpdateDelegate?
    
    func loadProfile(id: UUID) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1){ [weak self] in
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                if let profile = self.activeProfiles[id] {
                    self.activeProfile = profile
                    self.delegate?.profileDidUpdate(profile)
                }else {
                    let error = NSError(domain: "ProfileError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found"])
                    self.errorText = error.localizedDescription
                    self.delegate?.profileLoadingError(error)
                }
            }
            
        }
    }
    func loadProfile(username: String) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1){ [weak self] in
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                if let profile = self.activeProfiles.first(where: {$1.username == username })?.value {
                    self.activeProfile = profile
                    self.delegate?.profileDidUpdate(profile)
                }else {
                    let error = NSError(domain: "ProfileError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found"])
                    self.errorText = error.localizedDescription
                    self.delegate?.profileLoadingError(error)
                }
            }
            
        }
    }
    
    func addProfile(username: String, bio: String, avatarURL: String?){
        let uuid = UUID()
        activeProfiles[uuid] = UserProfile(id: uuid, username: username, avatarURL: avatarURL, bio: bio, followers: 0)
    }
    
    func removeProfile(id: UUID){
        activeProfiles.removeValue(forKey: id)
    }
}
