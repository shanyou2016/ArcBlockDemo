import SwiftUI
import SDWebImageSwiftUI

struct BlogDetailView: View {
    let blogPost: BlogPost
    @Environment(\.presentationMode) var presentationMode
    @State private var isSharePresented = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    // 封面图片区域
                    if let coverPath = blogPost.fullCoverImageURL,
                       let imageURL = URL(string: "https://www.arcblock.io/blog/uploads\(coverPath)?imageFilter=resize&w=800&f=webp") {
                        WebImage(url: imageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width)
                            .clipped()
                    } else {
                        Color.gray.opacity(0.1)
                            .frame(width: geometry.size.width, height: 250)
                    }
                    
                    // 文章标题
                    Text(blogPost.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // 作者和发布时间
                    HStack {
                        Text(blogPost.author)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(blogPost.formattedPublishTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // 摘要
                    Text(blogPost.excerpt)
                        .font(.body)
                        .padding(.horizontal)
                    
                    // 使用 htmlContent
                    if let content = blogPost.htmlContent {
                        Text(content)
                            .font(.body)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationBarItems(trailing: 
                Button(action: {
                    isSharePresented = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            )
            .sheet(isPresented: $isSharePresented) {
                ActivityViewController(activityItems: [
                    blogPost.title, 
                    URL(string: "https://www.arcblock.io/blog/\(blogPost.id)")!
                ])
            }
        }
    }
}

// 分享 Activity 控制器
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
