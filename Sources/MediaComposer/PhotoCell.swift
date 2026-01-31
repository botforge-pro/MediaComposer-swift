import SwiftUI
import UIKit

struct PhotoCell: View {
    let image: UIImage
    let isSelected: Bool
    let selectionIndex: Int?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()

                selectionIndicator
                    .padding(6)
            }
        }
        .buttonStyle(.plain)
        .aspectRatio(1, contentMode: .fill)
    }

    @ViewBuilder
    private var selectionIndicator: some View {
        if isSelected, let index = selectionIndex {
            Text("\(index)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
        } else {
            Circle()
                .strokeBorder(.white, lineWidth: 2)
                .frame(width: 24, height: 24)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
    }
}
