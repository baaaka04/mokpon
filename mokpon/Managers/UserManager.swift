import Foundation
import FirebaseFirestore

struct DBUser: Codable {
    let userId : String
    let isAnonymous : Bool?
    let email : String?
    let photoUrl : String?
    let dateCreated : Date?
    let name: String?
    let imageUrl: String?

    init(auth: AuthDataResultModel, name: String? = nil, imageUrl: String? = nil) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.name = name
        self.imageUrl = imageUrl
    }
}

final class UserManager {
    
    init() {print("\(Date()): INIT UserManager")}
    deinit {print("\(Date()): DEINIT UserManager")}
    
    private let userCollection = Firestore.firestore().collection("users") //if there's no collection in db, it will be created
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    // change keys to snakecase string during encoding to Firebase datatype
    private let encoder : Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
    }
    
    // change keys to camelcase string during dencoding from Firebase datatype
    private let decoder : Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func getUser (userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
    }
    
}
