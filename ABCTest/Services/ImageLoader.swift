//
//  ImageLoader.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import UIKit

// MARK: - ImageLoading Protocol

protocol ImageLoading: Sendable {
    func loadImage(from url: URL) async throws -> UIImage
    func cancelLoad(for url: URL) async
    func clearCache() async
    func prefetch(urls: [URL]) async
}

// MARK: - ImageLoader Implementation

final class ImageLoader: ImageLoading {
    
    // MARK: - Singleton
    
    static let shared = ImageLoader()
    
    // MARK: - Properties
    
    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession
    private let taskActor = ImageLoaderActor()
    
    // MARK: - Initialization
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = AppConstants.Configuration.requestTimeout
        configuration.timeoutIntervalForResource = AppConstants.Configuration.resourceTimeout
        self.session = URLSession(configuration: configuration)
        
        cache.countLimit = AppConstants.Configuration.cacheCountLimit
        cache.totalCostLimit = AppConstants.Configuration.cacheSizeLimit
    }
    
    // MARK: - Public Methods
    
    func loadImage(from url: URL) async throws -> UIImage {
        // Check cache first
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }
        
        // Check if there's an active task
        if let existingTask = await taskActor.getTask(for: url) {
            return try await existingTask.value
        }
        
        // Create new task
        let task = Task<UIImage, Error> {
            let (data, _) = try await session.data(from: url)
            
            guard let image = UIImage(data: data) else {
                throw ImageLoadError.invalidImageData
            }
            
            let cost = data.count
            cache.setObject(image, forKey: url as NSURL, cost: cost)
            
            await taskActor.removeTask(for: url)
            
            return image
        }
        
        await taskActor.setTask(task, for: url)
        
        return try await task.value
    }
    
    func cancelLoad(for url: URL) async {
        if let task = await taskActor.getTask(for: url) {
            task.cancel()
            await taskActor.removeTask(for: url)
        }
    }
    
    func clearCache() async {
        cache.removeAllObjects()
    }
    
    func prefetch(urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                if cache.object(forKey: url as NSURL) != nil {
                    continue
                }
                
                group.addTask {
                    try? await self.loadImage(from: url)
                }
            }
        }
    }
}

// MARK: - Actor for Thread-Safe Task Management

private actor ImageLoaderActor {
    private var tasks: [URL: Task<UIImage, Error>] = [:]
    
    func getTask(for url: URL) -> Task<UIImage, Error>? {
        return tasks[url]
    }
    
    func setTask(_ task: Task<UIImage, Error>, for url: URL) {
        tasks[url] = task
    }
    
    func removeTask(for url: URL) {
        tasks.removeValue(forKey: url)
    }
}

// MARK: - Error Types

enum ImageLoadError: Error {
    case invalidImageData
    case taskCancelled
}
