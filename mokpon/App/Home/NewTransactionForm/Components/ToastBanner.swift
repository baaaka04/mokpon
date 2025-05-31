import SwiftUI

enum ToastType: Equatable {
    case success(String)
    case error(String)

    var message: String {
        switch self {
        case .success(let msg), .error(let msg): return msg
        }
    }

    var backgroundColor: Color {
        switch self {
        case .success: return .green
        case .error: return .secondBackground
        }
    }
}


struct ToastBanner: View, Equatable {
    let type: ToastType

    static func == (lhs: ToastBanner, rhs: ToastBanner) -> Bool {
        lhs.type == rhs.type
    }

    var body: some View {
        Text(type.message)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(type.backgroundColor)
            .cornerRadius(12)
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}

protocol ToastPresentable {}

extension ToastPresentable {
    @MainActor
    func showToast(_ type: ToastType, binding: Binding<ToastType?>, duration: TimeInterval = 2) {
        binding.wrappedValue = type
        Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            withAnimation {
                binding.wrappedValue = nil
            }
        }
    }
}


#Preview {
    ToastBanner(type: .success("Test"))
}
