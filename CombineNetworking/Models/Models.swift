//
//  Models.swift
//  Experimentation+Combine
//
//  Created by Jullianm on 04/03/2020.
//  Copyright © 2020 Jullianm. All rights reserved.
//

import Foundation

struct Post: Codable, Hashable {
    let userId, id: Int
    let title, body: String
}

struct Comment: Codable {
    let postId, id: Int
    let name, email, body: String
}
