//
//  ContentView.swift
//  WordScramble
//
//  Created by Yuri Ramocan on 4/9/20.
//  Copyright © 2020 Yuri Ramocan. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var currentScore = 0
    @State private var newWord = ""
    @State private var rootWord = ""
    @State private var usedWords = [String]()

    // MARK: - Error Handling
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()

                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }

                Text("Score: \(currentScore)")
                    .font(.title)
            }
            .navigationBarTitle(rootWord.capitalized)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle),
                      message: Text(errorMessage),
                      dismissButton: .default(Text("OK")))
            }
            .navigationBarItems(leading:
                Button(action: {
                    self.startGame()
                }) {
                    Text("New word")
                }
            )
        }
    }

    private func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard !answer.isEmpty else { return }

        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original.")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }

        usedWords.insert(answer, at: 0)
        updateScore(with: answer)
        self.newWord = ""
    }

    private func startGame() {
        guard
            let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"),
            let startWords = try? String(contentsOf: startWordsURL)
            else {
                fatalError("Could not load start words.")
        }

        let allWords = startWords.components(separatedBy: "\n")
        rootWord = allWords.randomElement() ?? "silkworm"
    }

    private func updateScore(with word: String) {
        currentScore += word.count
    }

    private func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}


// MARK: - Word Validation
extension ContentView {
    private func isOriginal(word: String) -> Bool {
        !usedWords.contains(word) && (word != rootWord)
    }

    private func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()

        for letter in word {
            guard let pos = tempWord.firstIndex(of: letter) else {
                return false
            }

            tempWord.remove(at: pos)
        }

        return true
    }

    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
