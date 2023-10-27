//
//  ContentView.swift
//  extreme-look-ios
//
//  Created by Влад Важенин on 18.11.2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var isLoaderVisible = false
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                WebView(
                    type: .public,
                    preload: false,
                    url: self.viewModel.urlApp,
                    viewModel: viewModel
                )
            }.onReceive(self.viewModel.isLoaderVisible.receive(on: RunLoop.main)) { value in
                self.isLoaderVisible = value
            }
            if isLoaderVisible && !self.viewModel.loadApp {
                LoaderView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
