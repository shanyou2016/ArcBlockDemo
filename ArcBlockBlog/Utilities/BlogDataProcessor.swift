import Foundation
import OSLog
import CoreData

// 定义 Models 命名空间
enum Models {
    // 博客响应结构
    struct BlogResponse: Codable {
        let data: [BlogPost]
        let total: Int
        
        // 兼容旧代码的计算属性
        var blogPosts: [BlogPost] {
            return data
        }
    }

    // 博客数据结构
    struct BlogPost: Codable, Identifiable {
        let id: String
        let title: String
        let author: String
        let publishTime: String
        let excerpt: String
        let labels: [String]
        let commentCount: Int
        let fullCoverImageURL: String?
        let htmlContent: String?
    }
}

// 原始博客数据包装器
struct OriginalBlogDataWrapper: Decodable {
    let data: [OriginalBlogPost]
    let total: Int
}

// 原始博客数据结构
struct OriginalBlogPost: Decodable {
    let title: String
    let content: String?
    let excerpt: String
    let author: String
    let labels: [String]
    let commentCount: Int?
    let publishTime: String
    let id: String
    
    // 转换为 BlogPost
    func toBlogPost() -> Models.BlogPost {
        return Models.BlogPost(
            id: id,
            title: title,
            author: author,
            publishTime: publishTime,
            excerpt: excerpt,
            labels: labels,
            commentCount: commentCount ?? 0,
            fullCoverImageURL: nil,
            htmlContent: content
        )
    }
}

class BlogDataProcessor {
    private static let logger = Logger(subsystem: "io.arcblock.blog", category: "DataProcessor")
    
    // 处理原始博客数据并生成 BlogData.json
    static func processOriginalBlogData(from data: Data) {
        do {
            let decoder = JSONDecoder()
            let wrapper = try decoder.decode(OriginalBlogDataWrapper.self, from: data)
            
            // 转换为 BlogPost
            let blogPosts = wrapper.data.map { $0.toBlogPost() }
            
            // 创建博客响应
            let blogResponse = Models.BlogResponse(data: blogPosts, total: wrapper.total)
            
            // JSON 编码
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(blogResponse)
            
            // 写入文件
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent("BlogData.json")
            
            try jsonData.write(to: fileURL)
            
            logger.info("成功生成 BlogData.json，共 \(blogPosts.count) 篇博客")
        } catch {
            logger.error("处理博客数据时发生错误：\(error.localizedDescription)")
        }
    }
}
