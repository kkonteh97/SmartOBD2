//
//  ChatViewModel.swift
//  SMARTOBD2
//
//  Created by kemo konteh on 11/3/23.
//

import Foundation

//class ChatViewModel: ObservableObject {
//        @Published var messages: [Message] = []
//        @Published var currentMessage: String = ""
//
//        private let openAIService = OpenAIService()
//        func sendMessage(message: String) {
//                let newMessage = Message(id: UUID(), role: .user, content: message, createdAt: Date())
//                messages.append(newMessage)
//                currentMessage = ""
//
//            Task {
//                let response = await openAIService.sendMessage(messages: messages)
//                print(response as Any)
//
//                guard let receivedOpenAIMessage = response?.choices.first?.message else {
//                    print("No response from OpenAI")
//                    return
//                }
//                let receivedMessage = Message(id: UUID(), role: receivedOpenAIMessage.role, content: receivedOpenAIMessage.content, createdAt: Date())
//                await MainActor.run {
//                    messages.append(receivedMessage)
//            }
//        }
//    }
//}


// 
