//
//  WaveView.swift
//  you-get-GUI-for-mac
//
//  Created by LiYanan2004 on 2023/5/4.
//

import SwiftUI

struct WaveView: View {
    var value: Double
    var total: Double
    
    var body: some View {
        TimelineView(.animation) { time in
            let now = time.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                if value / total >= 1 {
                    context.fill(Rectangle().path(in: CGRect(origin: .zero, size: size)), with: .foreground)
                    return
                }
                let count = min(max(2, ceil(size.width / 80)), 5.0)
                let waveRadius = size.width * 2 / count / 2
                let baseY = size.height * (1.0 - value / total) + waveRadius
                context.fill(Rectangle().path(in: CGRect(x: 0, y: baseY, width: size.width, height: size.height * value / total)), with: .foreground)
                context.drawLayer { innerContext in
                    innerContext.addFilter(.blur(radius: waveRadius / 2))
                    let offscreenX = size.width / 2
                    for i in 0..<Int(count) {
                        if let symbol = innerContext.resolveSymbol(id: "wave") {
                            let offsetX = cos(now.remainder(dividingBy: 2) * .pi + Double(i) * 0.5) * size.width / 30.0
                            let offsetY = cos(now.remainder(dividingBy: 1) * .pi * 2 + Double(i) * 4)
                            let point = CGPoint(
                                x: Double(i * 2 + 1) * waveRadius - offscreenX + offsetX,
                                y: baseY + offsetY
                            )
                            let rect = CGRect(
                                x: point.x - waveRadius, y: point.y - waveRadius,
                                width: waveRadius * 2, height: waveRadius * 2
                            )
                            innerContext.draw(symbol, in: rect)
                        }
                    }
                }
            } symbols: {
                Circle().foregroundColor(.red).tag("wave")
            }
        }
    }
}

struct WaveView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [.teal, .cyan, .cyan.opacity(0.5)],
                startPoint: .bottom,
                endPoint: .top
            )
            .offset(y: 200)
//            .mask {
//                WaveView(value: 50, total: 100)
//            }
            let text: some View = {
                Text("50%")
                    .monospaced()
                    .font(.system(size: 50).bold())
                    .foregroundColor(.white)
            }()
            text
                .blendMode(.difference)
                .overlay(text.blendMode(.hue))
                .overlay(text.foregroundColor(.cyan).blendMode(.overlay))
                .overlay(text.foregroundColor(.white).blendMode(.overlay))
        }
    }
}
