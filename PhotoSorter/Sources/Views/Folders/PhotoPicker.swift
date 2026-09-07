import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

/// Wraps PHPickerViewController. This picker runs out-of-process, so the app
/// never gets direct access to the photo library (and can't see Hidden/
/// Recently Deleted albums) — the user explicitly hands over only what they
/// select here, which the app then copies into its own private vault.
struct PhotoPicker: UIViewControllerRepresentable {
    var selectionLimit: Int = 0 // 0 = no limit
    var onPick: ([Data]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = selectionLimit
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onPick: ([Data]) -> Void

        init(onPick: @escaping ([Data]) -> Void) {
            self.onPick = onPick
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard !results.isEmpty else { return }

            let group = DispatchGroup()
            var collected: [Data] = []
            let lock = NSLock()

            for result in results {
                group.enter()
                result.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                    if let data {
                        lock.lock()
                        collected.append(data)
                        lock.unlock()
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.onPick(collected)
            }
        }
    }
}
