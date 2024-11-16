import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    @State private var image: UIImage? = nil
    @State private var classification: String = "Ladda upp en bild för klassificering."
    
 
        

    var body: some View {
        VStack(spacing: 20) {
            Text("ResNet50 Klassificering")
                .font(.largeTitle)
                .padding()

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .border(Color.gray, width: 1)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .overlay(Text("Ingen bild vald").foregroundColor(.gray))
            }

            Button("Välj bild") {
                pickImage()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Text("Klassificering:")
                .font(.headline)

            Text(classification)
                .padding()
                .border(Color.gray, width: 1)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(image: $image, classification: $classification)
        }
    }

    @State private var isPickerPresented = false

    func pickImage() {
        isPickerPresented = true
    }
}
