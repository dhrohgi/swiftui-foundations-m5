//
//  LearningApp.swift
//  LearningApp
//
//  Created by dennis on 10/10/21.
//

import SwiftUI

@main
struct LearningApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(ContentModel())
        }
    }
}
