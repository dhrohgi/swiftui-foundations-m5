//
//  ProfileView.swift
//  LearningApp
//
//  Created by dennis on 6/19/22.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        
        Button {
            
            try! Auth.auth().signOut()
            
            model.checkLogin()
            
        } label: {
            Text("Signout")
        }

        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
