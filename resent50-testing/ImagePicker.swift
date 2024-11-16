import SwiftUI
import CoreML
import Vision

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var classification: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)

            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.classifyImage(image: uiImage)
            }
        }
    }
}

extension ImagePicker {
    func classifyImage(image: UIImage) {
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            classification = "Kunde inte ladda ResNet50-modellen."
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation],
               let firstResult = results.first {
                DispatchQueue.main.async {
                    classification = "\(firstResult.identifier) - \(firstResult.confidence * 100)% säkerhet"
                }
            } else {
                DispatchQueue.main.async {
                    classification = "Klassificeringen misslyckades."
                }
            }
        }

        guard let cgImage = image.cgImage else {
            classification = "Bilden kunde inte bearbetas."
            return
        }

        let handler = VNImageRequestHandler(cgImage: cgImage)
        do {
            try handler.perform([request])
        } catch {
            classification = "Ett fel uppstod vid klassificeringen: \(error.localizedDescription)"
        }
    }
}
