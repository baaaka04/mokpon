import SwiftUI

struct ProfileView: View {
    
    var user : DBUser? = nil
    
    var body: some View {
        VStack {
            Text("User ID: \(user?.userId ?? "not found")")
            
            if let isAnonymous = user?.isAnonymous {
                Text("Is Anonymous: \(isAnonymous.description.capitalized)")
            }
            if let photo = user?.photoUrl {
                Text("Photo URL: \(photo)")
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
