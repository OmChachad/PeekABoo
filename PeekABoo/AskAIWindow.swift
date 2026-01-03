//
//  AskAIWindow.swift
//  PeekABoo
//
//  Created by Om Chachad on 28/11/25.
//

import SwiftUI
import AVFoundation

struct AskAIWindow: View {
    @State var geminiClient = GeminiClient(apiKey: "")
    @State var synthesizer = AVSpeechSynthesizer()
    var imageData: UIImage
    @State private var prompt: String = ""
    @State private var response: String?
    @State private var hasFinishedGenerating = false
    
    @State private var isGenerating = false
    
    var body: some View {
        VStack {
            if let response {
                Text(response)
                    .multilineTextAlignment(.leading)
                    .padding(10)
                    .glassBackgroundEffect(in: .rect(cornerRadius: 20, style: .continuous))
            }
            
            HStack(spacing: 0) {
                InternalSearchBar(text: $prompt) {
                    Task {
                        await generateResponse()
                    }
                }
//                .padding(1)
                
                Group {
                    if isGenerating {
                        ProgressView()
                    } else {
                        Button("Send", systemImage: "arrow.up") {
                            Task {
                                await generateResponse()
                            }
                        }
                        .disabled(prompt.isEmpty)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.circle)
                        .labelStyle(.iconOnly)
                    }
                }
                .padding(.trailing, 15)
            }
            .glassBackgroundEffect(in: .capsule)
            .frame(width: 500, height: 100)
        }
//        .onChange(of: hasFinishedGenerating) {
//            if hasFinishedGenerating {
//
//            }
//        }
        .animation(.bouncy, value: response == nil)
    }
    
    func speak(content: String) {
        let utterance = AVSpeechUtterance(string: content)


        // Configure the utterance.
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8


        // Retrieve the US English voice.
        let voice = AVSpeechSynthesisVoice()


        // Assign the voice to the utterance.
        utterance.voice = voice
        
//        let synthesizer = AVSpeechSynthesizer()


        // Tell the synthesizer to speak the utterance.
        synthesizer.speak(utterance)
    }
    
    func generateResponse() async {
        Task {
            print("Prompt received.")
            
            isGenerating = true
            
            do {
//                        try await geminiClient.streamMessage(
//                            text: prompt,
//                            image: imageData
//                        ) { token in
//                            DispatchQueue.main.async {
//                                response += token
//                            }
//                        }
                response = try await geminiClient.sendMessage(text: prompt, image: imageData)
            } catch {
                print(error.localizedDescription)
            }
            
            hasFinishedGenerating = true
            isGenerating = false
            
            speak(content: response ?? "")
        }
    }
}
