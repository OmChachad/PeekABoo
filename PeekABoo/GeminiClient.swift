import Foundation
import UIKit

final class GeminiClient {

    // MARK: - Types

    struct Message: Codable {
        let role: String
        let content: [MessageContent]
    }

    struct MessageContent: Codable {
        let type: String
        let text: String?
        let image_url: ImageURL?

        struct ImageURL: Codable {
            let url: String
        }
    }

    struct ChatCompletionRequest: Codable {
        let model: String
        let messages: [Message]
        let stream: Bool?
    }

    // MARK: - Properties

    private let apiKey: String
    private let endpoint = URL(string: "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions")!
    private var conversation: [Message] = []

    // MARK: - Init

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Helpers

    private func base64(from image: UIImage) -> String? {
        guard let jpegData = image.jpegData(compressionQuality: 0.9) else { return nil }
        return jpegData.base64EncodedString()
    }

    // MARK: - Public API (unchanged)

    func sendMessage(
        text: String,
        image: UIImage,
        model: String = "gemini-2.5-flash"
    ) async throws -> String {
        
        guard let base64 = base64(from: image) else {
            throw NSError(domain: "GeminiClient", code: -1, userInfo: [NSLocalizedDescriptionKey : "Image encoding failed"])
        }

        let contents: [MessageContent] = [
            .init(type: "text", text: text, image_url: nil),
            .init(type: "image_url", text: nil, image_url: .init(url: "data:image/jpeg;base64,\(base64)"))
        ]
        
        conversation.append(Message(role: "system", content: [.init(type: "text", text: "You are an assistant on Apple Vision Pro helping the user get contextual information about the world around them. They will ask you a question about what they are seeing through their eyes, and you must provide a succint explanation that helps them out, appropriate the response length to the request and its context.", image_url: nil)]))
        conversation.append(Message(role: "user", content: contents))
        return try await sendRequestAndStoreResponse(model: model)
    }

    func sendMessage(
        text: String,
        model: String = "gemini-2.5-flash"
    ) async throws -> String {

        conversation.append(
            Message(role: "user", content: [.init(type: "text", text: text, image_url: nil)])
        )

        return try await sendRequestAndStoreResponse(model: model)
    }

    // MARK: - Streaming API (unchanged signatures)

    func streamMessage(
        text: String,
        image: UIImage,
        model: String = "gemini-2.5-flash",
        onToken: @escaping (String) -> Void
    ) async throws {

        guard let base64 = base64(from: image) else { return }

        let contents: [MessageContent] = [
            .init(type: "text", text: text, image_url: nil),
            .init(type: "image_url", text: nil, image_url: .init(url: "data:image/jpeg;base64,\(base64)"))
        ]

        conversation.append(Message(role: "user", content: contents))
        try await streamRequest(model: model, onToken: onToken)
    }

    func streamMessage(
        text: String,
        model: String = "gemini-2.5-flash",
        onToken: @escaping (String) -> Void
    ) async throws {

        conversation.append(
            Message(role: "user", content: [.init(type: "text", text: text, image_url: nil)])
        )

        try await streamRequest(model: model, onToken: onToken)
    }

    // MARK: - Shared non-streaming logic

    private func sendRequestAndStoreResponse(model: String) async throws -> String {
        let body = ChatCompletionRequest(model: model, messages: conversation, stream: false)
        let text = try await sendRequest(body)

        conversation.append(
            Message(role: "assistant", content: [.init(type: "text", text: text, image_url: nil)])
        )

        return text
    }

    // MARK: - Networking (non-streaming) — FIXED DECODER

    private func sendRequest(_ body: ChatCompletionRequest) async throws -> String {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: req)

        // ===== FIXED: HANDLE BOTH string AND block array =====
        struct Response: Decodable {
            struct Choice: Decodable {
                struct Msg: Decodable {
                    let role: String

                    let content: Content

                    enum Content: Decodable {
                        case text(String)
                        case blocks([Block])

                        struct Block: Decodable {
                            let type: String?
                            let text: String?
                        }

                        init(from decoder: Decoder) throws {
                            let container = try decoder.singleValueContainer()

                            if let s = try? container.decode(String.self) {
                                self = .text(s)
                                return
                            }

                            if let arr = try? container.decode([Block].self) {
                                self = .blocks(arr)
                                return
                            }

                            throw DecodingError.typeMismatch(
                                Content.self,
                                .init(codingPath: decoder.codingPath, debugDescription:
                                        "content was neither String nor [Block]")
                            )
                        }
                    }
                }

                let message: Msg
            }

            let choices: [Choice]
        }
        print(String(data: data, encoding: .utf8))
        let decoded = try JSONDecoder().decode(Response.self, from: data)

        let content = decoded.choices.first?.message.content

        switch content {
        case .text(let s):
            return s
        case .blocks(let blocks):
            return blocks.compactMap { $0.text }.joined()
        case .none:
            return ""
        }
    }

    // MARK: - Networking (streaming) — FIXED DECODER

    private func streamRequest(
        model: String,
        onToken: @escaping (String) -> Void
    ) async throws {

        let body = ChatCompletionRequest(model: model, messages: conversation, stream: true)

        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)

        let (bytes, _) = try await URLSession.shared.bytes(for: req)

        for try await line in bytes.lines {
            guard line.starts(with: "data: ") else { continue }

            let payload = String(line.dropFirst(6))
            if payload == "[DONE]" { break }

            guard let data = payload.data(using: .utf8) else { continue }

            struct StreamChunk: Decodable {
                struct Choice: Decodable {
                    struct Delta: Decodable {
                        struct Block: Decodable {
                            let type: String?
                            let text: String?
                        }
                        let content: [Block]?
                    }
                    let delta: Delta
                }
                let choices: [Choice]
            }

            do {
                let chunk = try JSONDecoder().decode(StreamChunk.self, from: data)
                let tokens = chunk.choices
                    .flatMap { $0.delta.content ?? [] }
                    .compactMap { $0.text }

                tokens.forEach(onToken)

            } catch {
                print("STREAM DECODING ERROR:", error)
                print("STREAM PAYLOAD:", payload)
            }
        }
    }
}
