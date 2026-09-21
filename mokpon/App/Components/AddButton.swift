import SwiftUI

struct AddButton: View {
        
    var body: some View {
        
        Image(systemName: "plus")
            .font(.system(size: 23))
            .padding(18)
            .customGlassEffect(in: Circle())
            .padding(20)
    }
    
}


struct AddButton_Previews: PreviewProvider {
    static var previews: some View {
        AddButton()
    }
}
