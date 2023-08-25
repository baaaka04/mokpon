import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension Query {
    // extend Firebase query with function to download ALL documents as an array in a collection and decode it to any type
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (products: [T], lastDocument: DocumentSnapshot?) where T: Decodable {
        let snapshot = try await self.getDocuments()
        
        let products = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return (products, snapshot.documents.last)
    }
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T: Decodable {
        try await getDocumentsWithSnapshot(as: type).products
    }
}
