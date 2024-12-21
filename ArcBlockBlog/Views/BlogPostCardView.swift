import SwiftUI
import SDWebImageSwiftUI

struct BlogPostCardView: View {
    let blogPost: BlogPost
    
    var body: some View {
        // 将复杂的视图构建拆分成更简单的部分
        VStack(alignment: .leading, spacing: 10) {
            // 封面图片
            coverImageView
            
            // 文章标题
            Text(blogPost.title)
                .font(.headline)
                .lineLimit(2)
            
            // 摘要
            Text(blogPost.excerpt)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // 底部信息
            bottomInfoView
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    private var coverImageView: some View {
        Group {
            if let coverPath = blogPost.fullCoverImageURL,
               let imageURL = URL(string: "https://www.arcblock.io/blog/uploads\(coverPath)?imageFilter=resize&w=400&f=webp") {
                WebImage(url: imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Color.gray.opacity(0.1)
                    .frame(height: 200)
                    .cornerRadius(8)
            }
        }
    }
    
    private var bottomInfoView: some View {
        HStack {
            Text(blogPost.author)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(blogPost.formattedPublishTime)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Image(systemName: "message")
                .foregroundColor(.secondary)
                .font(.caption)
            
            Text("\(blogPost.commentCount)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
