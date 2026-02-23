//
//  ImageLoadingService.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import UIKit

// MARK: - Image Loading Protocol

protocol ImageLoadingService: Sendable {
    func loadImage(from url: URL) async throws -> UIImage
    func cancelLoad(for url: URL)
    func clearCache()
    func prefetch(urls: [URL]) async
}

// MARK: - Image Loader Implementation

final class ImageLoader: ImageLoadingService {
    
    // MARK: - Properties
    
    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession
    private actor TaskManager {
        private var activeTasks: [URL: Task<UIImage, Error>] = [:]
        
        func setTask(_ task: Task<UIImage, Error>, for url: URL) {
            activeTasks[url] = task
        }
        
        func removeTask(for url: URL) {
            activeTasks[url]?.cancel()
            activeTasks.removeValue(forKey: url)
        }
        
        func getTask(for url: URL) -> Task<UIImage, Error>? {
            activeTasks[url]
        }
    }
    
    private let taskManager = TaskManager()
    
    // MARK: - Initialization
    
    init(session: URLSession? = nil) {
        if let session = session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 60
            let delegateQueue = OperationQueue()
            delegateQueue.maxConcurrentOperationCount = 4
            delegateQueue.qualityOfService = .userInitiated
            self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: delegateQueue)
        }
        
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    // MARK: - Public Methods
    
    func loadImage(from url: URL) async throws -> UIImage {
        // Check cache first
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }
        
        // Check if there's already a task for this URL
        if let existingTask = await taskManager.getTask(for: url) {
            return try await existingTask.value
        }
        
        // Create new task
        let task = Task<UIImage, Error> {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ImageLoadError.invalidResponse
            }
            
            guard let image = UIImage(data: data) else {
                throw ImageLoadError.invalidImageData
            }
            
            // Cache the image
            let cost = data.count
            cache.setObject(image, forKey: url as NSURL, cost: cost)
            
            await taskManager.removeTask(for: url)
            
            return image
        }
        
        await taskManager.setTask(task, for: url)
        
        return try await task.value
    }
    
    func cancelLoad(for url: URL) {
        Task {
            await taskManager.removeTask(for: url)
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func prefetch(urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                // Skip if already cached
                if cache.object(forKey: url as NSURL) != nil {
                    continue
                }
                
                group.addTask {
                    _ = try? await self.loadImage(from: url)
                }
            }
        }
    }
}

// MARK: - Errors

enum ImageLoadError: Error {
    case invalidResponse
    case invalidImageData
}
