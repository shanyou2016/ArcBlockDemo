//
//  ArcBlockBlogApp.swift
//  ArcBlockBlog
//
//  Created by 罗杰斯 on 2024/12/21.
//

import SwiftUI

@main
struct ArcBlockBlogApp: App {
    init() {
        // 在应用启动时加载缓存的博客数据
        if let url = Bundle.main.url(forResource: "BlogData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let blogResponse = try decoder.decode(Models.BlogResponse.self, from: data)
                
                // 缓存博客数据
                CacheManager.shared.cacheBlogPosts(blogResponse.data)
            } catch {
                print("加载博客数据失败：\(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                BlogListView()
            }
        }
    }
}

