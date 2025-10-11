import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> PreviewContainerView {
        let view = PreviewContainerView()
        view.attach(previewLayer: previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: PreviewContainerView, context: Context) {
        uiView.attach(previewLayer: previewLayer)
        uiView.updatePreviewFrame()
    }
    
    final class PreviewContainerView: UIView {
        private var attachedLayer: AVCaptureVideoPreviewLayer?
        
        func attach(previewLayer: AVCaptureVideoPreviewLayer) {
            guard attachedLayer !== previewLayer else {
                configure(previewLayer)
                return
            }
            
            attachedLayer?.removeFromSuperlayer()
            previewLayer.removeFromSuperlayer()
            
            configure(previewLayer)
            layer.addSublayer(previewLayer)
            attachedLayer = previewLayer
            updatePreviewFrame()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            updatePreviewFrame()
        }
        
        func updatePreviewFrame() {
            attachedLayer?.frame = bounds
        }
        
        private func configure(_ layer: AVCaptureVideoPreviewLayer) {
            layer.videoGravity = .resizeAspectFill
            if let connection = layer.connection {
                let portraitAngle: CGFloat = 90
                if connection.isVideoRotationAngleSupported(portraitAngle) {
                    connection.videoRotationAngle = portraitAngle
                }
                if connection.isVideoMirroringSupported {
                    connection.automaticallyAdjustsVideoMirroring = false
                    connection.isVideoMirrored = true
                }
            }
        }
    }
}
