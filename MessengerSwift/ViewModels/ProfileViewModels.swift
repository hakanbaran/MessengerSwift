//
//  ProfileViewModels.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 4.08.2023.
//

import Foundation


enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
