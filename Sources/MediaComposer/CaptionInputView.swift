import SwiftUI

struct CaptionInputView: View {
    @Binding var caption: String
    let selectionCount: Int
    let isSendEnabled: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField(L10n.mediaComposerCaptionPlaceholder, text: $caption)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray5))
                .clipShape(Capsule())

            sendButton
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }

    @ViewBuilder
    private var sendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(isSendEnabled ? .blue : .gray)
        }
        .disabled(!isSendEnabled)
    }
}
