import SwiftUI

struct CheckerboardView: View {
    let gridSize: CGFloat = 12
    let color1: Color = .white
    let color2: Color = Color(white: 0.92)
    
    var body: some View {
        Canvas { context, size in
            let rows = Int(ceil(size.height / gridSize))
            let cols = Int(ceil(size.width / gridSize))
            
            for row in 0..<rows {
                for col in 0..<cols {
                    let rect = CGRect(
                        x: CGFloat(col) * gridSize,
                        y: CGFloat(row) * gridSize,
                        width: gridSize,
                        height: gridSize
                    )
                    
                    let color = (row + col) % 2 == 0 ? color1 : color2
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
    }
}

#Preview {
    CheckerboardView()
        .frame(width: 300, height: 200)
}
