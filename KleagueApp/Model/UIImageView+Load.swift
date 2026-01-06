//
//  UIImageView+Load.swift
//  KleagueApp
//
//  Created by 최영건 on 8/15/25.
//

import UIKit

extension UIImageView {
    func setImage(from urlString: String?, placeholder: UIImage? = UIImage(systemName: "photo")) {
        self.image = placeholder
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        if let cached = ImageCache.shared.image(for: url.absoluteString) {
            self.image = cached
            return
        }
        
        URLSession.shared.dataTask(with: url) { data,  _, _ in
            guard let data = data, let img = UIImage(data: data) else { return }
            ImageCache.shared.set(img, for: url.absoluteString)
            DispatchQueue.main.async {
                self.image = img
            }
        }.resume()
    }
}

final class ImageCache {
    static let shared = ImageCache()
    private init() { }
    private var cache = NSCache<NSString, UIImage>()
    func image(for key: String) -> UIImage? { cache.object(forKey: key as NSString) }
    func set(_ img: UIImage, for key: String) { cache.setObject(img, forKey: key as NSString) }
}
