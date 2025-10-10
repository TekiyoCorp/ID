import SwiftUI

struct IdentitySetupView: View {
    @StateObject private var viewModel = IdentityViewModel()
    
    @FocusState private var nomFocused: Bool
    @FocusState private var prenomFocused: Bool
    @FocusState private var nationaliteFocused: Bool
    @FocusState private var metierFocused: Bool
    @FocusState private var villeFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if viewModel.currentStep == .nom {
                            VStack(alignment: .leading, spacing: 8) {
                                LargeTitle("Créer ton identité.")
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

                        if viewModel.currentStep != .nom {
                            Spacer(minLength: 0)
                        }

                        ZStack(alignment: .topLeading) {
                            ForEach(IdentityStep.allCases, id: \.self) { step in
                                stepView(for: step)
                                    .id("step_\(step.rawValue)")
                                    .opacity(viewModel.currentStep == step ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.25), value: viewModel.currentStep)
                            }
                        }
                        .frame(height: viewModel.currentStep == .nom ? 120 : nil)
                        .frame(maxHeight: viewModel.currentStep == .nom ? 120 : .infinity)
                        .padding(.top, 24)

                        if viewModel.currentStep != .nom {
                            Spacer(minLength: 0)
                        }

                        Spacer(minLength: 0)
                    }
                    .id("content")
                    .padding(.horizontal, 48)
                }
                .onChange(of: viewModel.currentStep) { _, newStep in
                    withAnimation { proxy.scrollTo("step_\(newStep.rawValue)", anchor: .top) }
                }
            }

            if viewModel.isCurrentStepComplete && viewModel.currentStep != .ville {
                PrimaryButton(
                    title: "Continuer",
                    style: .blue,
                    action: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            viewModel.advance()
                        }
                    }
                )
                .padding(.horizontal, 48)
                .padding(.bottom, 24)
            } else if viewModel.isComplete {
                PrimaryButton(
                    title: "Continuer",
                    style: .blue,
                    action: viewModel.proceedToPhotoCapture
                )
                .padding(.horizontal, 48)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear { focusCurrentStep() }
        .onChange(of: viewModel.currentStep) { _, _ in focusCurrentStep() }
        .navigationDestination(isPresented: $viewModel.shouldNavigateToPhotoCapture) {
            PhotoCaptureView(identityData: viewModel.buildIdentityData())
        }
        .debugRenders("IdentitySetupView")
    }

    @ViewBuilder
    private func stepView(for step: IdentityStep) -> some View {
        switch step {
        case .nom:
            inputField(
                title: step.title,
                text: $viewModel.nom,
                focused: $nomFocused
            )
        case .prenom:
            inputField(
                title: step.title,
                text: $viewModel.prenom,
                focused: $prenomFocused,
                centerVertically: true
            )
        case .naissance:
            VStack(alignment: .leading, spacing: 12) {
                LargeTitle(step.title)

                DatePicker("", selection: $viewModel.dateNaissance, displayedComponents: .date)
                    .datePickerStyle(.wheel)

                Button("Valider") {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        viewModel.advance()
                    }
                }
                .font(.system(size: 17, weight: .semibold))
                .appTypography(fontSize: 17)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        case .nationalite:
            VStack(alignment: .leading, spacing: 12) {
                TextField(step.placeholder, text: $viewModel.nationalite)
                    .font(.system(size: 36, weight: .medium))
                    .appTypography(fontSize: 36)
                    .foregroundStyle(.primary)
                    .focused($nationaliteFocused)
                    .submitLabel(.done)
                    .onSubmit {}
                    .onChange(of: viewModel.nationalite) { _, _ in
                        viewModel.showSuggestions = true
                    }
                
                if viewModel.showSuggestions && !viewModel.nationalite.isEmpty {
                    ForEach(viewModel.countrySuggestions, id: \.self) { suggestion in
                        Button(action: {
                            viewModel.selectCountry(suggestion)
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
        case .metier:
            VStack(alignment: .leading, spacing: 12) {
                TextField(step.placeholder, text: $viewModel.metier)
                    .font(.system(size: 36, weight: .medium))
                    .appTypography(fontSize: 36)
                    .foregroundStyle(.primary)
                    .focused($metierFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            viewModel.advance()
                        }
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
                    .onChange(of: viewModel.metier) { _, _ in
                        viewModel.showSuggestions = true
                    }
                
                if viewModel.showSuggestions && !viewModel.metier.isEmpty {
                    ForEach(viewModel.metierSuggestions, id: \.self) { suggestion in
                        Button(action: {
                            viewModel.selectMetier(suggestion)
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
        case .ville:
            inputField(
                title: step.title,
                text: $viewModel.ville,
                focused: $villeFocused,
                centerVertically: true
            )
        }
    }

    private func inputField(
        title: String,
        text: Binding<String>,
        focused: FocusState<Bool>.Binding,
        centerVertically: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if centerVertically {
                Spacer()
            }
            
            TextField(title, text: text)
                .font(.system(size: 36, weight: .medium))
                .appTypography(fontSize: 36)
                .foregroundStyle(.primary)
                .submitLabel(.done)
                .focused(focused)
                .onSubmit {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        viewModel.advance()
                    }
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
            
            if centerVertically {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func focusCurrentStep() {
        switch viewModel.currentStep {
        case .nom:
            nomFocused = true
        case .prenom:
            prenomFocused = true
        case .naissance:
            break
        case .nationalite:
            nationaliteFocused = true
        case .metier:
            metierFocused = true
        case .ville:
            villeFocused = true
        }
    }
}

#Preview {
    IdentitySetupView()
}
