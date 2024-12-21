import Foundation
import Combine
import OSLog

enum NetworkError: Error {
    case dataProcessingFailed
}

class NetworkManager {
    static let shared = NetworkManager()
    private let logger = Logger(subsystem: "com.arcblock.blog", category: "NetworkManager")
    
    private init() {}
    
    // 从本地 JSON 文件加载博客数据
    func loadBlogPosts(completion: @escaping (Result<Models.BlogResponse, Error>) -> Void) {
        guard let url = Bundle.main.url(forResource: "BlogData", withExtension: "json") else {
            completion(.failure(NSError(domain: "NetworkManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "博客数据文件未找到"])))
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let blogResponse = try decoder.decode(Models.BlogResponse.self, from: data)
            completion(.success(blogResponse))
        } catch {
            completion(.failure(error))
        }
    }
    
    // 异步加载博客数据
    func loadBlogPostsAsync() async throws -> Models.BlogResponse {
        return try await withCheckedThrowingContinuation { continuation in
            loadBlogPosts { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func ensureBlogData() -> AnyPublisher<[Models.BlogPost], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NetworkError.dataProcessingFailed))
                return
            }
            
            self.loadBlogPosts { result in
                switch result {
                case .success(let blogResponse):
                    self.logger.info("成功加载博客数据，共 \(blogResponse.data.count) 篇博客")
                    promise(.success(blogResponse.data))
                case .failure(let error):
                    self.logger.error("加载博客数据失败：\(error.localizedDescription)")
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}