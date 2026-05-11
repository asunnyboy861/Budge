import SwiftUI
import LocalAuthentication

struct BiometricLockView: View {
    @State private var isUnlocked = false
    @State private var errorMessage: String?
    @State private var isAuthenticating = false
    
    let onSuccess: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: biometricIcon)
                .font(.system(size: 64))
                .foregroundStyle(Color("BudgetGreen"))
            
            Text("Budge is Locked")
                .font(.title.bold())
            
            Text("Authenticate to access your budget data")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: authenticate) {
                if isAuthenticating {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Unlock")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color("BudgetGreen"))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(isAuthenticating)
            .padding(.horizontal, 40)
        }
        .onAppear {
            authenticate()
        }
    }
    
    private var biometricIcon: String {
        let type = BiometricAuthService.getBiometricType()
        switch type {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "lock.shield"
        }
    }
    
    private func authenticate() {
        isAuthenticating = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await BiometricAuthService.authenticate()
                if success {
                    isUnlocked = true
                    onSuccess()
                }
            } catch let error as BiometricAuthService.BiometricError {
                errorMessage = error.localizedDescription
            } catch {
                errorMessage = "Authentication failed. Please try again."
            }
            isAuthenticating = false
        }
    }
}

#Preview {
    BiometricLockView(onSuccess: {})
}
