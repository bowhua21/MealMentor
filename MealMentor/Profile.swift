struct Profile {
    var firstName: String?
    var lastName: String?
    var gender: String?
    var age: Int?
    var weight: Int?
    var height: Int?
    
    var fullName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""
        return "\(first) \(last)"
    }
    
    var heightFormatted: String {
        guard let height = height, height > 0 else { return "" }
        let feet = height / 12
        let inches = height % 12
        return "\(feet)' \(inches)\""
    }
}
