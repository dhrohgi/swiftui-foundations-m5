//
//  TestView.swift
//  LearningApp
//
//  Created by dennis on 10/18/21.
//

import SwiftUI

struct TestView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        
        ScrollView {
            
            LazyVStack {
                
                if model.currentModule != nil {
                    
                    VStack {
                        
                        // Question number
                        Text("Question \(model.currentQuestionIndex + 1) of \(model.currentModule?.test.questions.count ?? 0)")
                        
                        
                        // Question
                        CodeTextView()
                        
                        // Answers
                        
                        
                        //Button
                        
                    }
                    .navigationTitle("\(model.currentModule?.category ?? "") Test")
                }
                else {
                    ProgressView()
                }
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
            .environmentObject(ContentModel())
    }
}
