import Foundation
import FirebaseFirestore

class Meal {
    var documentID: String?  // Add this property
    var foodList: [Food]
    var date: Date
    var userID: String
    var category: String
    
    init(documentID: String? = nil, date: Date, userID: String, category: String, foodList: [Food] = []) {
        self.documentID = documentID
        self.date = date
        self.userID = userID
        self.category = category
        self.foodList = foodList
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "date": Timestamp(date: date),
            "userID": userID,
            "category": category,
            "foodList": foodList.map { $0.toDictionary() }
        ]
    }
    

    func saveToFirestore(completion: @escaping (Result<String, Error>) -> Void) {
        let db = Firestore.firestore()
        var ref: DocumentReference
        
        if let documentID = self.documentID {
            ref = db.collection("meals").document(documentID)
        } else {
            ref = db.collection("meals").document()
            self.documentID = ref.documentID
        }
        
        ref.setData(self.toDictionary()) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(ref.documentID))
            }
        }
    }
}
