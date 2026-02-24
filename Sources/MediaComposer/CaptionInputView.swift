import SwiftUI

struct CaptionInputView: View {
    @Binding var caption: String
    let selectionCount: Int
    let isSendEnabled: Bool
    let isSending: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField(L10n.mediaComposerCaptionPlaceholder, text: $caption)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray5))
                .clipShape(Capsule())
                .disabled(isSending)

            sendButton
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }

    @ViewBuilder
    private var sendButton: some View {
        if isSending {
            ProgressView()
                .frame(width: 32, height: 32)
        } else {
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(isSendEnabled ? .blue : .gray)
            }
            .disabled(!isSendEnabled)
        }
    }
}
