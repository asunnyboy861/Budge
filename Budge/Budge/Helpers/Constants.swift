import Foundation

enum Constants {
    static let bundlePrefix = "com.zzoutuo."
    static let appName = "Budge"
    static let monthlyProductId = "com.zzoutuo.Budge.monthly"
    static let yearlyProductId = "com.zzoutuo.Budge.yearly"
    static let feedbackBackendURL = "https://feedback-board.iocompile67692.workers.dev"
    static let githubPagesBase = "https://asunnyboy861.github.io/Budge"

    static let supportURL = URL(string: "\(githubPagesBase)/support.html")!
    static let privacyURL = URL(string: "\(githubPagesBase)/privacy.html")!
    static let termsURL = URL(string: "\(githubPagesBase)/terms.html")!

    enum Category {
        static let expenseCategories: [(name: String, icon: String)] = [
            ("Food", "🍔"),
            ("Coffee", "☕"),
            ("Transport", "🚗"),
            ("Shopping", "🛒"),
            ("Housing", "🏠"),
            ("Health", "💊"),
            ("Fun", "🎬"),
            ("Travel", "✈️"),
            ("Subs", "📱"),
            ("Other", "📝")
        ]

        static let incomeCategories: [(name: String, icon: String)] = [
            ("Salary", "💰"),
            ("Freelance", "💻"),
            ("Invest", "📈"),
            ("Gift", "🎁")
        ]
    }
}
