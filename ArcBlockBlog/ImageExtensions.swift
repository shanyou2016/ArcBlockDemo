import SwiftUI
import UIKit

extension Image {
    static let placeholder: Image = {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 200))
        let image = renderer.image { context in
            // 创建渐变
            let colors = [
                UIColor(white: 0.9, alpha: 1.0).cgColor,
                UIColor(white: 0.95, alpha: 1.0).cgColor
            ]
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil)!
            
            let startPoint = CGPoint(x: 0, y: 0)
            let endPoint = CGPoint(x: 0, y: 200)
            
            context.cgContext.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
            
            // 添加一个微妙的网格效果
            context.cgContext.setStrokeColor(UIColor(white: 0.85, alpha: 0.5).cgColor)
            context.cgContext.setLineWidth(0.5)
            
            for x in stride(from: 0, to: 300, by: 20) {
                context.cgContext.move(to: CGPoint(x: x, y: 0))
                context.cgContext.addLine(to: CGPoint(x: x, y: 200))
            }
            
            for y in stride(from: 0, to: 200, by: 20) {
                context.cgContext.move(to: CGPoint(x: 0, y: y))
                context.cgContext.addLine(to: CGPoint(x: 300, y: y))
            }
            
            context.cgContext.strokePath()
        }
        
        return Image(uiImage: image)
    }()
}