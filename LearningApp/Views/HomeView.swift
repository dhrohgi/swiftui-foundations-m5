//
//  HomeView.swift
//  LearningApp
//
//  Created by dennis on 10/10/21.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .leading) {
                
                Text("What do you want to do today?")
                    .padding(.leading, 20)
                
                ScrollView {
                    
                    LazyVStack {
                        
                        ForEach(model.modules) { module in
                            
                            VStack(spacing: 20) {
                                
                                NavigationLink(
                                    destination:
                                        ContentView()
                                        .onAppear(perform: {
                                                model.beginModule(module.id)
                                            }),
                                    tag: module.id,
                                    selection: $model.currentContentSelected) {
                                        // Learning Card
                                        HomeViewRow(
                                            image: module.content.image,
                                            title: "Learn \(module.category)",
                                            description: module.content.description,
                                            count: String(module.content.lessons.count) + " Lessons",
                                            time: module.content.time)
                                    }
                                
                                NavigationLink(
                                    destination:
                                        TestView()
                                        .onAppear(perform: {
                                                model.beginTest(module.id)
                                            }),
                                    tag: module.id,
                                    selection: $model.currentTestSelected) {
                                        // Test Card
                                        HomeViewRow(
                                            image: module.test.image,
                                            title: "\(module.category) Test",
                                            description: module.test.description,
                                            count: String(module.test.questions.count) + " Questions",
                                            time: module.test.time)
                                   }
                                
                                NavigationLink(destination: EmptyView()) {
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .accentColor(.black)
                    .padding()
                }
            }
            .navigationTitle("Get Started")
            
        }
        .navigationViewStyle(.stack)
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ContentModel())
    }
}
