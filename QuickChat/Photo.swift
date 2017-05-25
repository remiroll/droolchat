//
//  Photo.swift
//  Photos
//
//  Created by Duc Tran on 1/19/17.
//  Copyright © 2017 Developers Academy. All rights reserved.
//

import Foundation
import Firebase

struct PhotoCategory {
    var categoryImageName: String
    var title: String
    var imageNames: [String]
    
    static func fetchPhotos() -> [PhotoCategory] {
        var categories = [PhotoCategory]()
        let photosData = PhotosLibrary.downloadPhotosData()
        
        for (categoryName, dict) in photosData {
            if let dict = dict as? [String : Any] {
                let categoryImageName = dict["categoryImageName"] as! String
                if let imageNames = dict["imageNames"] as? [String] {
                    let newCategory = PhotoCategory(categoryImageName: categoryImageName, title: categoryName, imageNames: imageNames)
                    categories.append(newCategory)
                }
            }
        }
        
        return categories
    }
    
    
    
    
}

class PhotosLibrary
{
    class func downloadPhotosData() -> [String : Any]
    {
        
        return [
            "Recipes" : [
                "categoryImageName" : "recipes",
                "imageNames" : [String](),
            ],
            "Food" : [
                "categoryImageName" : "foods",
                "imageNames" : [String](),
            ],
            "Videos" : [
                "categoryImageName" : "videos",
                "imageNames" : [String](),
            ],
            "Favourites" : [
                "categoryImageName" : "favourites",
                "imageNames" : [String](),
            ]
        ]
    }
    
    private class func generateImage(categoryPrefix: String, numberOfImages: Int) -> [String] {
        var imageNames = [String]()
        
        for i in 1...numberOfImages {
            imageNames.append("\(categoryPrefix)\(i)")
        }
        
        return imageNames
    }
    
    class func getImageUrls(category: [Post]) -> [String] {
        
        var imageNames = [String]()
        
        for post in category {
            imageNames.append(post.pathToImage)
        }
        
        return imageNames
    }
    
    class func fetchPosts(completion: @escaping ([PhotoCategory]) -> ()){
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { snap in
            
            var recipes = [Post]()
            var food = [Post]()
            var videos = [Post]()
            var favourites = [Post]()
            
            for snapshot in snap.children {
                guard let snapshot = snapshot as? FIRDataSnapshot else { continue }
                
                let post = Post(snapshot: snapshot)
                
                switch (post.catagory) {
                    case "Recipes":
                        recipes.append(post)
                        break
                    case "Food":
                        food.append(post)
                    case "Videos":
                        videos.append(post)
                    case "Favourites":
                        favourites.append(post)
                default: break
                }
            }
            
            // posts are sorted
            
            let photosData = [
                "Recipes" : [
                    "categoryImageName" : "recipes",
                    "imageNames" : PhotosLibrary.getImageUrls(category: recipes),
                ],
                "Food" : [
                    "categoryImageName" : "foods",
                    "imageNames" : PhotosLibrary.getImageUrls(category: food),
                ],
                "Videos" : [
                    "categoryImageName" : "videos",
                    "imageNames" : PhotosLibrary.getImageUrls(category: videos),
                ],
                "Favourites" : [
                    "categoryImageName" : "favourites",
                    "imageNames" : PhotosLibrary.getImageUrls(category: favourites),
                ]
            ]
            
            var categories = [PhotoCategory]()
            
            for (categoryName, dict) in photosData {
                if let dict = dict as? [String : Any] {
                    let categoryImageName = dict["categoryImageName"] as! String
                    if let imageNames = dict["imageNames"] as? [String] {
                        let newCategory = PhotoCategory(categoryImageName: categoryImageName, title: categoryName, imageNames: imageNames)
                        categories.append(newCategory)
                    }
                }
            }
            
            completion(categories)
            
        })
    }
}








