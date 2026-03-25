import SwiftUI
import PhotosUI

struct VideoPickerVieww: View {
    
    @State private var showPicker = false
    @State private var videoURL: URL?
    
    var body: some View {
        VStack {
            Button("Select Video") {
                showPicker = true
            }
            
            if let url = videoURL {
                Text("Selected: \(url.lastPathComponent)")
                
                Button("Upload") {
                    uploadVideo(url: url)
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            VideoPicker { url in
                self.videoURL = url
            }
        }
    }
}

struct VideoPicker: UIViewControllerRepresentable {
    
    var onVideoPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .videos
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
        let parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let item = results.first?.itemProvider else { return }
            
            if item.hasItemConformingToTypeIdentifier("public.movie") {
                item.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                    guard let url = url else { return }
                    
                    // copy to temp (important!)
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                    
                    try? FileManager.default.copyItem(at: url, to: tempURL)
                    
                    DispatchQueue.main.async {
                        self.parent.onVideoPicked(tempURL)
                    }
                }
            }
        }
    }
}

func uploadVideo(url: URL) {
    
    var request = URLRequest(url: URL(string: "https://your-api.com/upload")!)
    request.httpMethod = "POST"
    
    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    var data = Data()
    
    let filename = url.lastPathComponent
    let mimeType = "video/mp4"
    
    // file data
    if let fileData = try? Data(contentsOf: url) {
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n".data(using: .utf8)!)
    }
    
    data.append("--\(boundary)--\r\n".data(using: .utf8)!)
    
    URLSession.shared.uploadTask(with: request, from: data) { _, response, error in
        if let error = error {
            print("Upload error:", error)
        } else {
            print("Upload success")
        }
    }.resume()
}
