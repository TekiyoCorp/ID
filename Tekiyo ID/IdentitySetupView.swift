import SwiftUI

struct IdentitySetupView: View {
    enum Step: Int, CaseIterable { case nom = 0, prenom, naissance, nationalite }

    @State private var step: Step = .nom
    @State private var nom: String = ""
    @State private var prenom: String = ""
    @State private var naissance: String = ""
    @State private var nationalite: String = ""

    @FocusState private var nomFocused: Bool
    @FocusState private var prenomFocused: Bool
    @FocusState private var nationaliteFocused: Bool

    @State private var containerWidth: CGFloat = 0
    @State private var showSuggestions: Bool = true

    private var progress: Double {
        let total = Double(Step.allCases.count)
        let completed = Double(step.rawValue) + ((step == .nationalite && !nationalite.isEmpty) ? 1.0 : 0.0)
        return min(1.0, completed / total)
    }

    private var progressWidth: CGFloat {
        CGFloat(progress) * containerWidth
    }

    private let countries: [String] = {
        let fr = Locale(identifier: "fr_FR")
        return Locale.isoRegionCodes.compactMap { fr.localizedString(forRegionCode: $0) }.sorted()
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if step == .nom {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Créer ton identité.")
                                    .font(.system(size: 36, weight: .medium))
                                    .appTypography(fontSize: 36)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .allowsTightening(true)
                                Text("Ces informations restent sur ton appareil.")
                                    .font(.system(size: 22, weight: .medium))
                                    .appTypography(fontSize: 22)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.top, 24)
                            .padding(.bottom, 86)
                            .frame(maxWidth: 237, alignment: .leading)
                        }

                        GeometryReader { geo in
                            Color.clear
                                .onAppear { containerWidth = geo.size.width }
                                .onChange(of: geo.size.width) { _, new in containerWidth = new }
                        }
                        .frame(height: 0)

                        if step != .nom {
                            Spacer(minLength: 0)
                        }

                        // Animated field area with simplified opacity transition
                        ZStack(alignment: .topLeading) {
                            ForEach(Step.allCases, id: \.self) { s in
                                stepView(for: s)
                                    .id("step_\(s.rawValue)")
                                    .opacity(step == s ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.25), value: step)
                            }
                        }
                        .frame(height: 120)
                        .padding(.top, 24)

                        if step != .nom {
                            Spacer(minLength: 0)
                        }

                        Spacer(minLength: 0)
                    }
                    .id("content")
                    .padding(.horizontal, 48)
                }
                .onChange(of: step) { _, newStep in
                    withAnimation { proxy.scrollTo("step_\(newStep.rawValue)", anchor: .top) }
                }
            }

            // Bottom fixed bar: progress + continue
            VStack(spacing: 12) {
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5)).frame(height: 8)
                    Capsule()
                        .fill(Color(red: 0.0, green: 0.187, blue: 1.0))
                        .frame(width: progressWidth, height: 8)
                }
                .accessibilityLabel("Progression")
                .accessibilityValue("\(Int(progress * 100)) pourcents")

                if step == .nationalite && !nationalite.isEmpty {
                    Button(action: { /* TODO: next */ }) {
                        Text("Continuer")
                            .font(.system(size: 17, weight: .semibold))
                            .appTypography(fontSize: 17)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 293, style: .continuous)
                            .fill(Color(red: 0.0, green: 0.187, blue: 1.0))
                    )
                }
            }
            .padding(.horizontal, 48)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear { focusCurrentStep() }
        .onChange(of: step) { _, _ in focusCurrentStep() }
    }

    @ViewBuilder
    private func stepView(for s: Step) -> some View {
        switch s {
        case .nom:
            inputField(title: "Nom", text: $nom, focused: $nomFocused) {
                advanceIfNeeded()
            }
        case .prenom:
            inputField(title: "Prénom", text: $prenom, focused: $prenomFocused) {
                advanceIfNeeded()
            }
        case .naissance:
            VStack(alignment: .leading, spacing: 12) {
                Text("Date de naissance")
                    .font(.system(size: 36, weight: .medium))
                    .appTypography(fontSize: 36)
                    .foregroundStyle(.primary)

                // Wheel style DatePicker (day/month/year columns)
                DatePicker("", selection: Binding(get: {
                    dateFromString(naissance) ?? Date()
                }, set: { newDate in
                    naissance = formatDate(newDate)
                }), displayedComponents: .date)
                .datePickerStyle(.wheel)

                Button("Valider") {
                    advanceIfNeeded()
                }
                .font(.system(size: 17, weight: .semibold))
                .appTypography(fontSize: 17)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        case .nationalite:
            VStack(alignment: .leading, spacing: 12) {
                TextField("Nationalité", text: $nationalite)
                    .font(.system(size: 36, weight: .medium))
                    .appTypography(fontSize: 36)
                    .foregroundStyle(.primary)
                    .focused($nationaliteFocused)
                    .submitLabel(.done)
                    .onSubmit { /* keep focus or handle */ }
                    .onChange(of: nationalite) { _, _ in showSuggestions = true }
                if showSuggestions && !nationalite.isEmpty {
                    ForEach(countrySuggestions(prefix: nationalite), id: \.self) { suggestion in
                        Button(action: {
                            nationalite = suggestion
                            showSuggestions = false
                        }) {
                            Text(suggestion)
                                .font(.system(size: 22, weight: .medium))
                                .appTypography(fontSize: 22)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
            .frame(maxWidth: 293, alignment: .leading)
            .clipped()
        }
    }

    private func advanceIfNeeded() {
        withAnimation(.easeInOut(duration: 0.35)) {
            if step == .nom && !nom.isEmpty { step = .prenom }
            else if step == .prenom && !prenom.isEmpty { step = .naissance }
            else if step == .naissance && !naissance.isEmpty { step = .nationalite }
        }
    }

    private func inputField(title: String, text: Binding<String>, focused: FocusState<Bool>.Binding, onCommit: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField(title, text: text)
                .font(.system(size: 36, weight: .medium))
                .appTypography(fontSize: 36)
                .foregroundStyle(.primary)
                .submitLabel(.done)
                .focused(focused)
                .onSubmit {
                    onCommit()
                }
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)
                .padding(.vertical, 8)
                .overlay(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func focusCurrentStep() {
        switch step {
        case .nom:
            nomFocused = true
        case .prenom:
            prenomFocused = true
        case .naissance:
            break
        case .nationalite:
            nationaliteFocused = true
        }
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale = Locale.current
        return f.string(from: date)
    }
    private func dateFromString(_ s: String) -> Date? {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale = Locale.current
        return f.date(from: s)
    }

    private func countrySuggestions(prefix: String) -> [String] {
        let p = prefix.lowercased()
        return countries.filter { $0.lowercased().hasPrefix(p) }.prefix(5).map { $0 }
    }
}

#Preview {
    IdentitySetupView()
}
