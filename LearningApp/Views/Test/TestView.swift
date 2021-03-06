//
//  TestView.swift
//  LearningApp
//
//  Created by dennis on 10/18/21.
//

import SwiftUI

struct TestView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State private var selectedAnswerIndex: Int?
    @State private var submitted = false
    
    @State private var numCorrect = 0
    
    var body: some View {
        
        if model.currentQuestion != nil {
            
            VStack(alignment: .leading) {
                
                // Question number
                Text("Question \(model.currentQuestionIndex + 1) of \(model.currentModule?.test.questions.count ?? 0)")
                    .padding(.leading, 20)
                
                // Question
                CodeTextView()
                    .padding([.leading, .trailing], 20)
                
                // Answers
                ScrollView {
                    
                    VStack {
                        ForEach(0..<model.currentQuestion!.answers.count, id:\.self) { index in
                            
                            Button {
                                // Track the selected index
                                selectedAnswerIndex = index
                            } label: {
                                ZStack {
                                    
                                    if submitted == false {
                                        RectangleCard(color: index == selectedAnswerIndex ? .gray : .white)
                                            .frame(height: 48)
                                    }
                                    else {
                                        // User has selected the right answer
                                        if index == selectedAnswerIndex && index == model.currentQuestion!.correctIndex {
                                            RectangleCard(color: .green)
                                                .frame(height: 48)
                                        }
                                        // User has selected the wrong answer
                                        else if index == selectedAnswerIndex && index != model.currentQuestion!.correctIndex {
                                            RectangleCard(color: .red)
                                                .frame(height: 48)
                                        }
                                        else if index == model.currentQuestion!.correctIndex {
                                            RectangleCard(color: .green)
                                                .frame(height: 48)
                                        }
                                        else {
                                            RectangleCard(color: .white)
                                                .frame(height: 48)
                                        }
                                    }
                                    Text(model.currentQuestion!.answers[index])
                                }
                            }
                            .disabled(submitted)
                        }
                    }
                    .padding()
                    .accentColor(.black)
                }
                
                // Submit Button
                Button {
                    
                    // Check if answer has been submitted
                    if submitted == true {
                        // Answer has already been submitted, move to next question
                        model.nextQuestion()
                        
                        // Reset properties
                        submitted = false
                        selectedAnswerIndex = nil
                    }
                    else {
                        // Submit the answer
                        
                        // Change submitted state to true
                        submitted = true
                        // Check if selected answer is correct and increment the counter if correct
                        if selectedAnswerIndex == model.currentQuestion!.correctIndex {
                            numCorrect += 1
                        }
                    }
                } label: {
                    ZStack {
                        RectangleCard(color: .green)
                            .frame(height: 48)
                        Text(buttonText)
                            .foregroundColor(.white)
                            .bold()
                    }
                    .padding()
                }
                .disabled(selectedAnswerIndex == nil)
            }
            .navigationTitle("\(model.currentModule?.category ?? "") Test")
        }
        else {
            // If current questions is not nil, show the test result
            TestResultView(numCorrect: numCorrect)
        }
    }
    
    // Computed property - ????????? ?????? ?????? string ??? ???????????? ??????.
    var buttonText: String {
        
        // Check if answer has been submitted
        if submitted == true {
            if model.currentQuestionIndex + 1 == model.currentModule!.test.questions.count {
                return "Finish"
            }
            else {
                return "Next"
            }
        }
        else {
            return "Submit"
        }
        
    }
}


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
            .environmentObject(ContentModel())
    }
}
