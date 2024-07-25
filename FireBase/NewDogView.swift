//
//  NewDogView.swift
//  PhotoApp
//
//  Created by Abraham May on 7/24/24.
//

import SwiftUI

struct NewDogView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var newDog = ""
    
    var body: some View {
        VStack {
            TextField("Dog", text: $newDog)
            
            Button {
                dataManager.addDog(dogBreed: newDog)
            } label: {
                Text("Save")
            }

        }
        .padding()
    }
}

#Preview {
    NewDogView()
}
