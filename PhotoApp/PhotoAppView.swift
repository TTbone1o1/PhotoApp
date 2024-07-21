//
//  PhotoAppView.swift
//  PhotoApp
//
//  Created by Abraham May on 7/21/24.
//

import SwiftUI

struct PhotoAppView: View {
    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: 200, height: 200)
            .cornerRadius(20)
        Image(systemName: "star.fill")
            .foregroundColor(.yellow)
            
    }
}

#Preview {
    ViewController()
}
