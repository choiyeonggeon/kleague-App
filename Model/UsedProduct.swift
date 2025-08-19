//
//  UsedProduct.swift
//  KleagueApp
//
//  Created by 최영건 on 8/12/25.
//

import Foundation
import FirebaseFirestore

struct UsedProduct {
    let id: String
    let title: String
    let price: String
    let description: String
    let imageUrl: String
    let sellerUid: String
    let sellerName: String
    let createdAt: Date
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.title = data["title"] as? String ?? ""
        self.price = data["price"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.imageUrl = data["imageUrl"] as? String ?? ""
        self.sellerUid = data["sellerUid"] as? String ?? ""
        self.sellerName = data["sellerName"] as? String ?? "판매자"
        if let ts = data["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = Date()
        }
    }
}
