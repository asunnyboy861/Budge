import Foundation
import LocalAuthentication

struct BiometricAuthService {
    
    enum BiometricError: Error {
        case notAvailable
        case notEnrolled
        case lockedOut
        case authenticationFailed
        case userCancel
        case unknown
        
        var localizedDescription: String {
            switch self {
            case .notAvailable:
                return "Biometric authentication is not available on this device."
            case .notEnrolled:
                return "No biometric identity is enrolled. Please set up Face ID or Touch ID in Settings."
            case .lockedOut:
                return "Biometric authentication is locked out. Please try again later."
            case .authenticationFailed:
                return "Authentication failed. Please try again."
            case .userCancel:
                return "Authentication was cancelled."
            case .unknown:
                return "An unknown error occurred."
            }
        }
    }
    
    static func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    static func getBiometricType() -> LABiometryType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        return context.biometryType
    }
    
    static func authenticate() async throws -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Use Passcode"
        
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                throw mapError(error)
            }
            throw BiometricError.notAvailable
        }
        
        let reason = "Authenticate to access Budge"
        
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return success
        } catch {
            throw mapError(error as NSError)
        }
    }
    
    private static func mapError(_ error: NSError) -> BiometricError {
        switch error.code {
        case LAError.biometryNotAvailable.rawValue:
            return .notAvailable
        case LAError.biometryNotEnrolled.rawValue:
            return .notEnrolled
        case LAError.biometryLockout.rawValue:
            return .lockedOut
        case LAError.authenticationFailed.rawValue:
            return .authenticationFailed
        case LAError.userCancel.rawValue:
            return .userCancel
        default:
            return .unknown
        }
    }
}
