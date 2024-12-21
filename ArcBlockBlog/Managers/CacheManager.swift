import Foundation
import CoreData

// 扩展 BlogPostEntity 以添加 coverImageURL
extension BlogPostEntity {
    @NSManaged var coverImageURL: String?
}

class CacheManager {
    // 单例模式
    static let shared = CacheManager()
    
    // 私有初始化方法，防止外部实例化
    private init() {}
    
    // 缓存博客文章
    func cacheBlogPosts(_ posts: [Models.BlogPost]) {
        let context = persistentContainer.viewContext
        
        posts.forEach { post in
            let blogPostEntity = BlogPostEntity(context: context)
            blogPostEntity.id = post.id
            blogPostEntity.title = post.title
            blogPostEntity.author = post.author
            blogPostEntity.publishTime = post.publishTime
            blogPostEntity.excerpt = post.excerpt
            blogPostEntity.labels = post.labels.joined(separator: ",")
            blogPostEntity.commentCount = Int32(post.commentCount)
            blogPostEntity.cover = post.fullCoverImageURL
            blogPostEntity.htmlContent = post.htmlContent
        }
        
        do {
            try context.save()
        } catch {
            print("缓存博客文章失败: \(error)")
        }
    }
    
    // 获取缓存的博客文章
    func getCachedBlogPosts() -> [Models.BlogPost] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BlogPostEntity> = BlogPostEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { entity in
                Models.BlogPost(
                    id: entity.id ?? "",
                    title: entity.title ?? "",
                    author: entity.author ?? "",
                    publishTime: entity.publishTime ?? "",
                    excerpt: entity.excerpt ?? "",
                    labels: entity.labels?.components(separatedBy: ",") ?? [],
                    commentCount: Int(entity.commentCount),
                    fullCoverImageURL: entity.cover,
                    htmlContent: entity.htmlContent
                )
            }
        } catch {
            print("获取缓存博客文章失败: \(error)")
            return []
        }
    }
    
    // 清除缓存的博客文章
    func clearCachedBlogPosts() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BlogPostEntity> = BlogPostEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(fetchRequest)
            entities.forEach { context.delete($0) }
            try context.save()
        } catch {
            print("清除缓存博客文章失败: \(error)")
        }
    }
    
    // 保存上下文
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Core Data 堆栈
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BlogCache")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}