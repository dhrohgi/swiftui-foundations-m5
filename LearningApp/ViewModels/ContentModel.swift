//
//  ContentModel.swift
//  LearningApp
//
//  Created by dennis on 10/10/21.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth


class ContentModel: ObservableObject {
    
    // Authentication
    @Published var loggedIn = false
    
    let db = Firestore.firestore()
    
    // List of modules
    @Published var modules = [Module]()
    
    // Current module
    @Published var currentModule: Module?
    var currentModuleIndex = 0
    
    // Current lesson
    @Published var currentLesson: Lesson?
    var currentLessonIndex = 0
    
    // Current question
    @Published var currentQuestion: Question?
    var currentQuestionIndex = 0
    
    // Current lesson explanation
    @Published var codeText = NSAttributedString()
    
    var styleData: Data?
    
    // Current selected content and test
    @Published var currentContentSelected: Int?
    @Published var currentTestSelected: Int?
    
    
    init() {
        
    }
    
    // MARK: Authentication methods
    
    func checkLogin() {
        
        // Check if there's a current user to determine logged in status
        loggedIn = Auth.auth().currentUser != nil ? true : false
        
        // Check if user meta data has been fetched. if the user was already logged in from a previous session, we need to get their data in a separate call
        if UserService.shared.user.name == "" {
            getUserData()
        }
        
    }
    
    func getUserData() {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        // Get the meta data for that user
        let db = Firestore.firestore()
        let ref = db.collection("users").document(Auth.auth().currentUser!.uid)
        ref.getDocument { snapshot, error in
            
            guard error == nil, snapshot != nil else {
                return
            }
            
            // Parse the data out and set the user meta data
            let data = snapshot!.data()
            let user = UserService.shared.user
            user.name = data?["name"] as? String ?? ""
            user.lastModule = data?["lastModule"] as? Int
            user.lastLesson = data?["lastLesson"] as? Int
            user.lastQuestion = data?["lastQuestion"] as? Int
                        
        }
        
    }
    
    func getDatabaseData() {
        
        // Parse local included json data
        getLocalStyle()
        
        // Specify path
        let collection = db.collection("modules")
        
        // Get documents
        collection.getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                // Create an array for the modules
                var modules = [Module]()
                
                // Loop through the documents returned
                for doc in snapshot!.documents {
                    
                    // Create a new module instance
                    // empty Module() 을 인자를 채우지 않고 생성하기 위해서 Module Class 에 초기값을 넣어줘야 한다.
                    var m = Module()
                    
                    // Parse out the values from the document into the module instance
                    m.id = doc["id"] as? String ?? UUID().uuidString
                    m.category = doc["category"] as? String ?? ""
                    
                    // Parse the content
                    let contentMap = doc["content"] as! [String:Any]
                    
                    m.content.id = contentMap["id"] as? String ?? ""
                    m.content.description = contentMap["description"] as? String ?? ""
                    m.content.image = contentMap["image"] as? String ?? ""
                    m.content.time = contentMap["time"] as? String ?? ""
                    
                    // Parse the test
                    let testMap = doc["test"] as! [String:Any]
                    
                    m.test.id = testMap["id"] as? String ?? ""
                    m.test.description = testMap["description"] as? String ?? ""
                    m.test.image = testMap["image"] as? String ?? ""
                    m.test.time = testMap["time"] as? String ?? ""
                    
                    // Add it to our array
                    modules.append(m)
                }
                
                // Assign our modules to the published property
                // 이 항목은 viewcode 에 영향을 미치기 때문에 DispatchQueue 구문을 포함시켜야 한다.
                DispatchQueue.main.async {
                    self.modules = modules
                }
                
            }
            
        }
        
    }
    
    
    // MARK: Data Methods
    
    func getLessons(module: Module, completion: @escaping () -> Void) {
        
        // Specify path
        let collection = db.collection("modules").document(module.id).collection("lessons")
        
        // Get documents
        collection.getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                // Array to track lessons
                var lessons = [Lesson]()
                
                // Loop through the documents and build array of lessons
                for doc in snapshot!.documents {
                    
                    var l = Lesson()
                    
                    l.id = doc["id"] as? String ?? UUID().uuidString
                    l.title = doc["title"] as? String ?? ""
                    l.video = doc["video"] as? String ?? ""
                    l.duration = doc["duration"] as? String ?? ""
                    l.explanation = doc["explanation"] as? String ?? ""
                    
                    // Add the lesson to the array
                    lessons.append(l)
                }
                
                // Setting the lessons to the module
                // Loop through published modules array and find the one that matches the id of the copy that got passed in
                for (index, m) in self.modules.enumerated() {
                    
                    // Find the module we want
                    if m.id == module.id {
                        
                        // Set the lessons
                        self.modules[index].content.lessons = lessons
                        
                        // Call the completion closure
                        completion()
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func getQuestions(module: Module, completion: @escaping () -> Void) {
        
        let collection = db.collection("modules").document(module.id).collection("questions")
        
        collection.getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                var questions = [Question]()
                
                for doc in snapshot!.documents {
                    
                    var q = Question()
                    
                    q.id = doc["id"] as? String ?? ""
                    q.content = doc["content"] as? String ?? ""
                    q.correctIndex = doc["correctIndex"] as? Int ?? 0
                    q.answers = doc["answers"] as? [String] ?? [String]()
                    
                    questions.append(q)
                    
                }
                
                for (index, m) in self.modules.enumerated() {
                    
                    if m.id == module.id {
                        
                        self.modules[index].test.questions = questions
                        
                        completion()
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    

    
    // MARK: Data methods
    func getLocalStyle() {
        /*
        // Parse the local json file
        
        // Get a url path to the json file
        let jsonUrl = Bundle.main.url(forResource: "data", withExtension: "json")

        // Read the file into a data object
        do {
            
            let jsonData = try Data(contentsOf: jsonUrl!)
            
            // Try to decode the json into an array of modules
            let jsonDecoder = JSONDecoder()
            let modules = try jsonDecoder.decode([Module].self, from: jsonData)
            
            // Assign parsed modules to modules property
            self.modules = modules
            
        }
        catch {
            print(error)
        }
        */
        
        // Parse the style data
        let styleUrl = Bundle.main.url(forResource: "style", withExtension: "html")
        
        do {
            
            let styleData = try Data(contentsOf: styleUrl!)
            self.styleData = styleData
            
        }
        catch {
            print(error)
        }
        
        
    }
    
    func getRemoteDate() {
        
        // String path
        let urlString = "https://dhrohgi.github.io/learningapp-data/data2.json"
        
        // Create a url object
        let url = URL(string: urlString)
        
        guard url != nil else {
            // Couldn't create url
            return
        }
        
        // Create a URLRequest object
        let request = URLRequest(url: url!)
        
        // Get the session and kick off the task
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            // Check if there's an error
            guard error == nil else {
                // There was an error
                return
            }
    
            do {
                // Create json decoder
                let decoder = JSONDecoder()
                
                // Decode
                let modules = try decoder.decode([Module].self, from: data!)
                print(modules)
                
                DispatchQueue.main.async {
                    // Append parsed modules into modules property
                    self.modules += modules
                }
                
            }
            catch {
                // Couldn't parse json
            }   
        }
        
        // Kick off data task
        dataTask.resume()
        
    }
    
    // MARK: Module navigation methods
    func beginModule(_ moduleid: String) {
        
        // Find the index for this module id
        for index in 0..<modules.count {
            if modules[index].id == moduleid {
                // Found the matching module
                currentModuleIndex = index
                break
            }
        }
        
        // Set the current module
        currentModule = modules[currentModuleIndex]
        
    }
    
    func beginLesson(_ lessonIndex: Int) {
        
        if lessonIndex < currentModule!.content.lessons.count {
            currentLessonIndex = lessonIndex
        }
        else {
            currentLessonIndex = 0
        }
        
        // Set the current lesson
        currentLesson = currentModule!.content.lessons[currentLessonIndex]
        codeText = addStyling(currentLesson!.explanation)
        
    }
    
    func nextLesson() {
        
        currentLessonIndex += 1
        
        if currentLessonIndex < currentModule!.content.lessons.count {
            currentLesson = currentModule!.content.lessons[currentLessonIndex]
            codeText = addStyling(currentLesson!.explanation)
        }
        else {
            currentLessonIndex = 0
            currentLesson = nil
        }
        
    }
    
    
    func hasNextLesson() -> Bool {
        
        // Return 뒤의 항목이 참이면 True, 거짓이면 False 를 반납한다.
        return (currentLessonIndex + 1 < currentModule!.content.lessons.count)
        
    }
    
    func beginTest(_ moduleId: String) {
        
        // Set the current module
        beginModule(moduleId)
        
        // Set the current question index
        currentQuestionIndex = 0
        
        // If there are questions, set the current question to the first one
        if currentModule?.test.questions.count ?? 0 > 0 {
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            codeText = addStyling(currentQuestion!.content)
        }
        
    }
    
    func nextQuestion() {
        
        // Advance the question index
        currentQuestionIndex += 1
        
        // Check that it's within the range of questions
        if currentQuestionIndex < currentModule!.test.questions.count {
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            codeText = addStyling(currentQuestion!.content)
        }
        else {
            currentQuestionIndex = 0
            currentQuestion = nil
        }
        
    }
    
    private func addStyling(_ htmlString: String) -> NSAttributedString {
        
        var resultString = NSAttributedString()
        var data = Data()
        
        if styleData != nil {
            data.append(styleData!)
        }
        
        data.append(Data(htmlString.utf8))
        
        // 옵셔녈 바인딩과 try? 키워드를 사용한 구문
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil) {
            resultString = attributedString
        }
        
        
        // Do-Try-Catch 를 사용한 구문
//        do {
//            let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
//            resultString = attributedString
//        }
//        catch {
//            print(error)
//        }
        
        return resultString
        
    }
    
}
