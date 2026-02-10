//
//  ImageLoader.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import UIKit

final class ImageLoader {
    
    // MARK: - Singleton
    
    static let shared = ImageLoader()
    
    // MARK: - Properties
    
    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession
    private var activeTasks: [URL: URLSessionDataTask] = [:]
    private let taskQueue = DispatchQueue(label: "com.abctest.imageloader.taskqueue")
    
    // MARK: - Initialization
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        let delegateQueue = OperationQueue()
        delegateQueue.maxConcurrentOperationCount = 4
        delegateQueue.qualityOfService = .userInitiated
        self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: delegateQueue)
        
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    // MARK: - Public Methods
    
    @discardableResult
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) -> ImageLoadTask {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return ImageLoadTask(url: url, loader: self)
        }
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            self.taskQueue.async {
                self.activeTasks.removeValue(forKey: url)
            }
            
            guard let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let cost = data.count
            self.cache.setObject(image, forKey: url as NSURL, cost: cost)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        taskQueue.async {
            self.activeTasks[url] = task
        }
        task.resume()
        
        return ImageLoadTask(url: url, loader: self)
    }
    
    func cancelLoad(for url: URL) {
        taskQueue.async {
            self.activeTasks[url]?.cancel()
            self.activeTasks.removeValue(forKey: url)
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func prefetch(urls: [URL]) {
        for url in urls {
            if cache.object(forKey: url as NSURL) != nil {
                continue
            }
            
            loadImage(from: url) { _ in }
        }
    }
}


final class ImageLoadTask {
    private let url: URL
    private weak var loader: ImageLoader?
    
    init(url: URL, loader: ImageLoader) {
        self.url = url
        self.loader = loader
    }
    
    func cancel() {
        loader?.cancelLoad(for: url)
    }
}

