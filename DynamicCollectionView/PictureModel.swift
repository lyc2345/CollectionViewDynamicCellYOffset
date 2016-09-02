//
//  PictureModel.swift
//  DynamicCollectionView
//
//  Created by Stan Liu on 31/08/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import UIKit

struct Picture {
    
    let url: String
}

protocol PicturePresentable {
    
    var urlString: String { get }
}

extension Picture: PicturePresentable {
    
    var urlString: String { return url }
}



// Functors and Monads

enum ImageError: ErrorType { case NoData, ParsingError }

enum Result<T> {
    case Success(T)
    case Failure(ErrorType)
}

extension Result {
    func map<U>(f: T->U) -> Result<U> {
        switch self {
        case .Success(let t): return .Success(f(t))
        case .Failure(let err): return .Failure(err)
        }
    }
    func flatMap<U>(f: T->Result<U>) -> Result<U> {
        switch self {
        case .Success(let t): return f(t)
        case .Failure(let err): return .Failure(err)
        }
    }
}

extension Result {
    // Return the value if it's a .Success or throw the error if it's a .Failure
    func resolve() throws -> T {
        switch self {
        case Result.Success(let value): return value
        case Result.Failure(let error): throw error
        }
    }
    
    // Construct a .Success if the expression returns a value or a .Failure if it throws
    init(@noescape _ throwingExpr: Void throws -> T) {
        do {
            let value = try throwingExpr()
            self = Result.Success(value)
        } catch {
            self = Result.Failure(error)
        }
    }
}

struct DemoPhoto {
    
    let data: NSData
    
    init(data: NSData) throws {
        self.data = data
    }
}

protocol DemoPhotoDownloadable: class {
    
    func fetchImage(urlString: String, completion: Result<NSData> -> Void)
}

extension DemoPhotoDownloadable {
    
    typealias ImageBuilder = Void throws -> DemoPhoto
    func fetchImage(urlString: String, completion: Result<NSData> -> Void) {
        
        guard let url = NSURL(string: urlString) else {
            return
        }
        
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in
            
            completion(Result {
                
                if let error = error { throw error }
                guard let data = data else { throw ImageError.NoData }
                return data
                })
            }.resume()
    }

    func buildDemoPhoto(data: NSData) -> Result<DemoPhoto> {
        
        return Result { return try DemoPhoto(data: data) }
    }
    
    func readImage(photo: DemoPhoto) -> Result<UIImage> {
        
        return Result {
            
            guard let image = UIImage(data: photo.data) else {
                throw ImageError.NoData
            }
            return image
        }
    }
}