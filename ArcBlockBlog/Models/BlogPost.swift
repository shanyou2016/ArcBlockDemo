import Foundation

// 1. 日期格式化工具
struct DateHelper {
    static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    static let chineseFormatter: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter
    }()
}

// 2. 博客响应结构体
struct BlogResponse: Codable {
    let data: [BlogPost]
    let total: Int

    var blogPosts: [BlogPost] {
        return data
    }
}

// 3. 博客标签枚举（可选）
enum BlogLabel: String, Codable {
    case technology
    case lifestyle
    case programming
    case design
    case pressRelease = "press-release"
    case other
    
    // 添加自定义解码方法，处理未知标签
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let labelString = try container.decode(String.self)
        
        // 尝试匹配已知标签，否则使用 other
        self = BlogLabel(rawValue: labelString.lowercased()) ?? .other
    }
}

// 4. 博客数据模型
struct BlogPost: Identifiable, Codable {
    let id: String
    let title: String
    let author: String
    let publishTime: Date
    let formattedPublishTime: String
    let excerpt: String
    let labels: [BlogLabel]
    let commentCount: Int
    let fullCoverImageURL: URL?
    let htmlContent: String?
    
    // 5. 自定义编码键
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case author
        case publishTime = "lastCommentedAt"
        case excerpt
        case labels
        case commentCount
        case fullCoverImageURL = "cover"
        case htmlContent
    }
    
    // 6. 自定义解码初始化器
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        excerpt = try container.decode(String.self, forKey: .excerpt)
        
        // 解析日期
        let publishTimeString = try container.decodeIfPresent(String.self, forKey: .publishTime)
        publishTime = publishTimeString.flatMap { DateHelper.isoFormatter.date(from: $0) } ?? Date()
        
        // 格式化日期
        formattedPublishTime = DateHelper.chineseFormatter.string(from: publishTime)
        
        // 解析标签
        labels = try container.decodeIfPresent([BlogLabel].self, forKey: .labels) ?? []
        
        commentCount = try container.decodeIfPresent(Int.self, forKey: .commentCount) ?? 0
        htmlContent = try container.decodeIfPresent(String.self, forKey: .htmlContent)
        
        // 转换图片 URL
        let coverURLString = try container.decodeIfPresent(String.self, forKey: .fullCoverImageURL)
        fullCoverImageURL = coverURLString.flatMap { URL(string: $0) }
    }
    
    // 7. 便利初始化方法
    init(
        id: String,
        title: String,
        author: String = "佚名",
        publishTime: Date = Date(),
        excerpt: String,
        labels: [BlogLabel] = [],
        commentCount: Int = 0,
        fullCoverImageURL: URL? = nil,
        htmlContent: String? = nil
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.publishTime = publishTime
        self.formattedPublishTime = DateHelper.chineseFormatter.string(from: publishTime)
        self.excerpt = excerpt
        self.labels = labels
        self.commentCount = commentCount
        self.fullCoverImageURL = fullCoverImageURL
        self.htmlContent = htmlContent
    }
}

// 8. 扩展：博客文章的额外功能
extension BlogPost {
    // 计算属性：是否为最近发布的文章
    var isRecent: Bool {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return publishTime > thirtyDaysAgo
    }
    
    // 方法：获取文章阅读时间估算
    func estimatedReadingTime() -> Int {
        let wordsPerMinute = 200
        let wordCount = htmlContent?.components(separatedBy: .whitespacesAndNewlines).count ?? 0
        return wordCount / wordsPerMinute
    }
}