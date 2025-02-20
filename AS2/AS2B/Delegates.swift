//
//  Delegates.swift
//  AS2B
//
//  Created by kakim nyssanov on 20.02.2025.
//
import SwiftUI

protocol ProfileManagerDelegate: AnyObject {
    func didAddProfile(_ profile: UserProfile)
}

protocol PostManagerDelegate: AnyObject {
    func didAddPost(_ post: Post)
    func didLikePost(_ post: Post)
}
