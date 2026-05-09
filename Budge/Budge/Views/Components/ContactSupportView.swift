import SwiftUI

struct ContactSupportView: View {
    @State private var selectedSubject = "General"
    @State private var customSubject = ""
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    private let subjects = [
        "General",
        "Feature Suggestion",
        "Bug Report",
        "Usage Question",
        "Performance Issue",
        "UI Improvement",
        "Other"
    ]

    var body: some View {
        Form {
            Section {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(subjects, id: \.self) { subject in
                        Button(action: { selectedSubject = subject }) {
                            Text(subject)
                                .font(.caption)
                                .lineLimit(1)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                                .frame(maxWidth: .infinity)
                                .background(selectedSubject == subject ? Color("BudgetGreen").opacity(0.2) : Color.gray.opacity(0.1))
                                .foregroundStyle(selectedSubject == subject ? Color("BudgetGreen") : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedSubject == subject ? Color("BudgetGreen") : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                if selectedSubject == "Other" {
                    TextField("Specify your topic", text: $customSubject)
                        .textFieldStyle(.roundedBorder)
                }
            } header: {
                Text("Subject")
            }

            Section {
                TextField("Your name", text: $name)
                TextField("Your email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }

            Section {
                TextEditor(text: $message)
                    .frame(minHeight: 120)
            } header: {
                Text("Message")
            }

            Section {
                Button(action: submitFeedback) {
                    if isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Submit")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSubmit ? Color("BudgetGreen") : Color.gray.opacity(0.3))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .disabled(!canSubmit || isSubmitting)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Contact Support")
        .alert("Thank you!", isPresented: $showSuccess) {
            Button("OK") { dismissView() }
        } message: {
            Text("Your feedback has been submitted successfully.")
        }
    }

    private var canSubmit: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !message.isEmpty &&
        (selectedSubject != "Other" || !customSubject.isEmpty)
    }

    private var effectiveSubject: String {
        selectedSubject == "Other" ? customSubject : selectedSubject
    }

    private func submitFeedback() {
        isSubmitting = true
        errorMessage = nil

        let request = FeedbackRequest(
            name: name,
            email: email,
            subject: effectiveSubject,
            message: message,
            app_name: Constants.appName
        )

        guard let url = URL(string: "\(Constants.feedbackBackendURL)/api/feedback") else {
            errorMessage = "Invalid server URL"
            isSubmitting = false
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            errorMessage = "Failed to encode request"
            isSubmitting = false
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    showSuccess = true
                } else {
                    errorMessage = "Server error. Please try again."
                }
            }
        }.resume()
    }

    private func dismissView() {
        name = ""
        email = ""
        message = ""
        customSubject = ""
        selectedSubject = "General"
        errorMessage = nil
    }
}

struct FeedbackRequest: Codable {
    let name: String
    let email: String
    let subject: String
    let message: String
    let app_name: String
}
