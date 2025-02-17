import SwiftUI

struct ShutterAnimation: View {
    @State private var position: CGPoint = .zero
    
    var body: some View {
        GeometryReader { proxy in
            let proxyWidth = proxy.size.width * 0.5
            let proxyHeight = proxy.size.height * 0.5
            
            Canvas { context, size in
                context.addFilter(.alphaThreshold(min: 0.8, color: .blue))
                context.addFilter(.blur(radius: 22))
                
                context.drawLayer { ctx in
                    ctx.fill(Circle().path(in: CGRect(x: proxyWidth + position.x - 50,
                                                       y: proxyWidth + position.y - 50,
                                                       width: 120, height: 120)), with: .foreground)
                    ctx.fill(Circle().path(in: CGRect(x: proxyWidth - 150,
                                                       y: proxyHeight - 300,
                                                       width: 300, height: 300)), with: .foreground)
                }
            }
            .gesture(DragGesture()
                .onChanged { gesture in
                    position = CGPoint(x: gesture.translation.width, y: gesture.translation.height)
                }
            )
        }
    }
}

#Preview {
    ShutterAnimation()
}
