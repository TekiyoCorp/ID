import SwiftUI
import AVFoundation
import PhotosUI

struct PhotoCaptureView: View {
    let identityData: IdentityData?
    @StateObject private var viewModel: PhotoCaptureViewModel
    @State private var showImagePicker = false
    @State private var showCamera = false
    @Environment(\.scenePhase) private var phase
    
    init(identityData: IdentityData? = nil) {
        self.identityData = identityData
        self._viewModel = StateObject(wrappedValue: PhotoCaptureViewModel(identityData: identityData))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)
            
            // Camera icon
            Image(systemName: "camera")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.black)
            
            // Title
            LargeTitle("Prends toi en photo.", alignment: .center)
            
            // Subtitle - 6px gap from title, 2 lines
            Text("Cette image restera sur ton appareil,\nelle servira à prouver ton identité")
                .font(.system(size: 18, weight: .medium))
                .appTypography(fontSize: 18)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
                .padding(.top, 6)
            
            Spacer()
            
            // Camera preview circle
            ZStack {
                // Dashed circle
                Circle()
                    .stroke(Color(red: 0.0, green: 0.187, blue: 1.0), style: StrokeStyle(lineWidth: 2, dash: [8, 8]))
                    .frame(width: 253, height: 253)
                
                // Camera preview or captured image
                if let image = viewModel.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 253, height: 253)
                        .clipShape(Circle())
                } else if let previewLayer = viewModel.previewLayer {
                    // Live camera preview
                    CameraPreview(previewLayer: previewLayer)
                        .frame(width: 253, height: 253)
                        .clipShape(Circle())
                } else {
                    // Camera preview placeholder
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(width: 253, height: 253)
                        .clipShape(Circle())
                        .overlay {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .onTapGesture {
                viewModel.handleCaptureCircleTap()
            }
            
            // Instructions - 2 lines
            Text("Regarde droit devant.\nPas de filtre. Bonne lumière.")
                .font(.system(size: 18, weight: .medium))
                .appTypography(fontSize: 18)
                .foregroundStyle(.primary)
                .opacity(0.7)
                .multilineTextAlignment(.center)
            
            // Debug info and permission handling
            if !viewModel.canAccessCamera() {
                VStack(spacing: 12) {
                    Text(viewModel.cameraPermissionMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    if viewModel.cameraPermissionStatus == .denied {
                        Button("Ouvrir les Réglages") {
                            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsURL)
                            }
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else if viewModel.cameraPermissionStatus == .notDetermined {
                        Button("Autoriser l'accès à la caméra") {
                            viewModel.requestCameraPermission()
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.top, 8)
            }
            
            Spacer()
            
            // Take photo button
            PrimaryButton(
                title: viewModel.capturedImage != nil ? "Continuer" : "Prendre une photo",
                style: .blue,
                isEnabled: true,
                action: {
                    viewModel.handlePrimaryButtonTap()
                }
            )
            .padding(.horizontal, 48)
            
            // Import from gallery link - 28px gap from button
            Button("Importer depuis la galerie") {
                showImagePicker = true
            }
            .font(.system(size: 17, weight: .medium))
            .appTypography(fontSize: 17)
            .foregroundStyle(Color(red: 0.0, green: 0.187, blue: 1.0))
            .padding(.top, 28)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $viewModel.capturedImage)
        }
        .onAppear {
            viewModel.requestCameraPermission()
        }
        .onDisappear {
            viewModel.stopCameraSession()
        }
        .onChange(of: phase) { _, newPhase in
            if newPhase == .active {
                viewModel.resumeCameraIfNeeded()
            } else {
                viewModel.stopCameraSession()
            }
        }
        .navigationDestination(isPresented: $viewModel.shouldNavigateToFingerprintCreation) {
            FingerprintCreationView(
                identityData: identityData,
                capturedImage: viewModel.capturedImage
            )
        }
        .debugRenders("PhotoCaptureView")
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

#Preview {
    PhotoCaptureView()
}
