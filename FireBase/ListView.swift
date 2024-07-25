//
//  ListView.swift
//  PhotoApp
//
//  Created by Abraham May on 7/24/24.
//
 
import SwiftUI

struct ListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showPopup = false
    
    
    var body: some View{
        NavigationView {
            List(dataManager.dogs, id: \.id) { dog in
                Text(dog.breed)
            }
            .navigationTitle("Dogs")
            .navigationBarItems(trailing: Button(action : {
                showPopup.toggle()
            }, label: {
                Image(systemName: "plus")
            }))
            .sheet(isPresented: $showPopup){
                NewDogView()
            }
        }
    }
}
    
#Preview {
        ListView()
        .environmentObject(DataManager())
    }
