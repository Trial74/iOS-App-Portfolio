//
//  LoaderView.swift
//  extreme-look-ios
//
//  Created by Влад Важенин on 09.01.2023.
//

import SwiftUI

struct LoaderView: View {
    @ObservedObject var viewModel = ViewModel()
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                WebView(
                    type: .public,
                    preload: true,
                    url: self.viewModel.urlPreload,
                    viewModel: viewModel
                )
            }
        }
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderView()
    }
}
