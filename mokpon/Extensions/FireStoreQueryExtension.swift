import Foundation
import FirebaseFirestore

extension Query {
    // extend Firebase query with function to download ALL documents as an array in a collection and decode it to any type
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (documents: [T], lastDocument: DocumentSnapshot?) where T: Decodable {
        let snapshot = try await self.getDocuments()
        
        let documents = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return (documents, snapshot.documents.last)
    }
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T: Decodable {
        try await getDocumentsWithSnapshot(as: type).documents
    }
    
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else { return self }
        return self.start(afterDocument: lastDocument)
    }
}
