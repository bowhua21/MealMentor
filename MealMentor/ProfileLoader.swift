import FirebaseAuth
import FirebaseFirestore

class ProfileLoader {
    
    func loadProfile(completion: @escaping (Profile) -> Void) {
        let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
        var profile = Profile()
        let group = DispatchGroup()
        
        group.enter()
        getDocumentData(from: userDoc, category: "firstName") { value, error in
            if let firstName = value as? String {
                profile.firstName = firstName
            }
            group.leave()
        }
        
        group.enter()
        getDocumentData(from: userDoc, category: "lastName") { value, error in
            if let lastName = value as? String {
                profile.lastName = lastName
            }
            group.leave()
        }
        
        group.enter()
        getDocumentData(from: userDoc, category: "gender") { value, error in
            if let gender = value as? String {
                profile.gender = gender
            }
            group.leave()
        }
        
        group.enter()
        getDocumentData(from: userDoc, category: "age") { value, error in
            if let age = value as? Int, age != 0 {
                profile.age = age
            }
            group.leave()
        }
        
        group.enter()
        getDocumentData(from: userDoc, category: "weight") { value, error in
            if let weight = value as? Int, weight != 0 {
                profile.weight = weight
            }
            group.leave()
        }
        
        group.enter()
        getDocumentData(from: userDoc, category: "height") { value, error in
            if let height = value as? Int, height != 0 {
                profile.height = height
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(profile)
        }
    }
}
