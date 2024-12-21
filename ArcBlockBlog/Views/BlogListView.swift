import SwiftUI
import SDWebImageSwiftUI

struct BlogListView: View {
    @StateObject private var viewModel = BlogListViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.blogPosts) { post in
                        NavigationLink(destination: BlogDetailView(blogPost: post)) {
                            BlogPostCardView(blogPost: post)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: UIScreen.main.bounds.width - 20)
                        .onAppear {
                            viewModel.loadMorePostsIfNeeded(post)
                        }
                    }
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
                .padding(.horizontal, 10)  // 列表内容左右边距
               .padding(.top, 0)  // 显式设置顶部间距为0
            }
            .scrollIndicators(.hidden)  // 隐藏滚动指示器
            .contentMargins(.top, 0, for: .scrollContent)  // 设置顶部内容边距为0
            .navigationTitle("ArcBlock")  // 使用系统导航栏标题
            .navigationBarTitleDisplayMode(.inline)  // 设置标题显示模式
            .scrollContentBackground(.hidden)  // 隐藏滚动内容背景
            .edgesIgnoringSafeArea(.top)  // 忽略顶部安全区域
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
