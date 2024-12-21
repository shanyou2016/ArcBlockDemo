import Foundation
import Combine
import SDWebImage
import SDWebImageSwiftUI

// 1. 定义数据加载协议
protocol BlogDataLoading {
    func fetchBlogPosts(completion: @escaping (Result<[BlogPost], Error>) -> Void)
}

// 2. 本地 JSON 数据加载器
class LocalJSONBlogDataLoader: BlogDataLoading {
    func fetchBlogPosts(completion: @escaping (Result<[BlogPost], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let url = Bundle.main.url(forResource: "BlogData", withExtension: "json"),
                  let data = try? Data(contentsOf: url) else {
                completion(.failure(NSError(domain: "DataLoadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法读取 BlogData.json"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let blogResponse = try decoder.decode(BlogResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(blogResponse.data))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

// 3. 图片缓存配置
struct ImageCacheConfiguration {
    let maxMemoryCount: Int
    let maxDiskSizeInBytes: UInt
    
    static let `default` = ImageCacheConfiguration(
        maxMemoryCount: 100,
        maxDiskSizeInBytes: 1000 * 1024 * 1024
    )
}

// 4. 主 ViewModel
class BlogListViewModel: ObservableObject {
    @Published var blogPosts: [BlogPost] = []
    @Published var isLoading = false
    @Published var currentPage = 1
    
    private let blogDataLoader: BlogDataLoading
    private let imageCache: SDImageCache
    private let imageCacheConfig: ImageCacheConfiguration
    private var cancellables = Set<AnyCancellable>()
    
    // 依赖注入的构造函数
    init(
        dataLoader: BlogDataLoading = LocalJSONBlogDataLoader(),
        imageCache: SDImageCache = .shared,
        cacheConfig: ImageCacheConfiguration = .default
    ) {
        self.blogDataLoader = dataLoader
        self.imageCache = imageCache
        self.imageCacheConfig = cacheConfig
        
        configureImageCache()
        fetchBlogPosts()
    }
    
    // 配置图片缓存
    private func configureImageCache() {
        imageCache.config.maxMemoryCount = UInt(imageCacheConfig.maxMemoryCount)
        imageCache.config.maxDiskSize = imageCacheConfig.maxDiskSizeInBytes
        
        if let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let imageCachePath = cachesDirectory.appendingPathComponent("SDWebImageCache")
            
            try? FileManager.default.createDirectory(at: imageCachePath, withIntermediateDirectories: true)
            
            imageCache.config.diskCacheExpireType = .accessDate
        }
    }
    
    // 获取博客数据
    func fetchBlogPosts() {
        isLoading = true
        blogDataLoader.fetchBlogPosts { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let posts):
                self.blogPosts = posts
                self.isLoading = false
            case .failure(let error):
                print("获取博客失败: \(error)")
                self.isLoading = false
            }
        }
    }
    
    // 加载更多博客
    func loadMorePostsIfNeeded(_ post: BlogPost) {
        guard shouldLoadMorePosts(post) else { return }
        
        currentPage += 1
        fetchBlogPosts()
    }
    
    // 判断是否需要加载更多
    private func shouldLoadMorePosts(_ post: BlogPost) -> Bool {
        guard let index = blogPosts.firstIndex(where: { $0.id == post.id }) else { 
            return false 
        }
        return index >= blogPosts.count - 2
    }
    
    // 清除图片缓存
    func clearImageCache() {
        imageCache.clearMemory()
        imageCache.clearDisk()
    }
    
    // 缓存单个图片
    func cacheImage(url: URL) {
        SDWebImageManager.shared.loadImage(
            with: url,
            options: .highPriority,
            progress: nil
        ) { [weak self] (image, data, error, cacheType, finished, url) in
            if let error = error {
                print("图片缓存失败: \(error)")
            }
        }
    }
}
