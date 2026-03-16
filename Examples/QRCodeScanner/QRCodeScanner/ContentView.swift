//
//  ContentView.swift
//  QRCodeScanner
//
//  Created by Om Chachad on 15/03/26.
//

import PeekABoo
import SwiftUI
import UIKit
import Vision

struct ContentView: View {
    @Environment(\.openURL) private var openURL

    @State private var scannedPayload = "Take a screenshot of a QR code to scan it."
    @State private var detectionState = DetectionState.idle
    @State private var sheetResult: ScannedResult?

    var body: some View {
        VStack(spacing: 24) {
            Text("QR Code Scanner")
                .font(.largeTitle)
                .fontWeight(.semibold)

            PeekABoo.CaptureInstructions(
                description: "Point the headset at a QR code and then capture to read its contents."
            )
            .frame(maxWidth: 420)

            VStack(spacing: 12) {
                Text(detectionState.title)
                    .font(.headline)
                    .foregroundStyle(detectionState.tint)

                Text(scannedPayload)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .textSelection(.enabled)
                    .frame(maxWidth: 620)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .padding(32)
        .sheet(item: $sheetResult) { result in
            ResultSheet(result: result)
        }
        .onCapture { image in
            detectionState = .scanning
            scannedPayload = "Analyzing latest screenshot..."
            sheetResult = nil

            Task {
                let result = await QRCodeDetector.scan(image: image)

                switch result {
                case .success(let payload):
                    detectionState = .detected
                    scannedPayload = payload

                    if let url = URLParser.url(from: payload) {
                        scannedPayload = "Opening \(url.absoluteString)"
                        openURL(url)
                    } else {
                        scannedPayload = "QR code detected."
                        sheetResult = ScannedResult(payload: payload)
                    }
                case .failure(.notFound):
                    detectionState = .notFound
                    scannedPayload = "No QR code was found in that screenshot."
                case .failure(.unreadableImage):
                    detectionState = .failed
                    scannedPayload = "Could not read the captured image."
                case .failure(.visionFailed(let error)):
                    detectionState = .failed
                    scannedPayload = "Scan failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

private struct ScannedResult: Identifiable {
    let id = UUID()
    let payload: String
}

private struct ResultSheet: View {
    let result: ScannedResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "qrcode")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("QR Code Result")
                .font(.title2)
                .fontWeight(.semibold)

            ScrollView {
                Text(result.payload)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: 220)
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .frame(minWidth: 420, maxWidth: 520)
    }
}

private enum URLParser {
    static func url(from payload: String) -> URL? {
        guard let components = URLComponents(string: payload.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }

        guard let scheme = components.scheme?.lowercased(), ["http", "https"].contains(scheme) else {
            return nil
        }

        return components.url
    }
}

private enum DetectionState {
    case idle
    case scanning
    case detected
    case notFound
    case failed

    var title: String {
        switch self {
        case .idle:
            "Ready to Scan"
        case .scanning:
            "Scanning Screenshot"
        case .detected:
            "QR Code Detected"
        case .notFound:
            "Nothing Found"
        case .failed:
            "Scan Failed"
        }
    }

    var tint: Color {
        switch self {
        case .idle, .scanning:
            .primary
        case .detected:
            .green
        case .notFound:
            .orange
        case .failed:
            .red
        }
    }
}

private enum QRCodeDetector {
    enum ScanError: Error {
        case notFound
        case unreadableImage
        case visionFailed(Error)
    }

    static func scan(image: UIImage) async -> Result<String, ScanError> {
        await Task.detached(priority: .userInitiated) {
            let request = VNDetectBarcodesRequest()
            request.symbologies = [.qr]

            do {
                try perform(request: request, with: image)

                guard let match = request.results?.first(where: { observation in
                    observation.symbology == .qr && observation.payloadStringValue?.isEmpty == false
                }), let payload = match.payloadStringValue else {
                    return .failure(.notFound)
                }

                return .success(payload)
            } catch let error as ScanError {
                return .failure(error)
            } catch {
                return .failure(.visionFailed(error))
            }
        }.value
    }

    private static func perform(request: VNDetectBarcodesRequest, with image: UIImage) throws {
        if let cgImage = image.cgImage {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])
            return
        }

        if let ciImage = CIImage(image: image) {
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            try handler.perform([request])
            return
        }

        throw ScanError.unreadableImage
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
