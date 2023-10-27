//
//  ViewModel.swift
//  extreme-look-ios
//
//  Created by Влад Важенин on 09.01.2023.
//

import Foundation
import Combine

class ViewModel: ObservableObject {
    var host = "-----//-----";
    var param = "-----//-----";
    var loadApp = false;
    var isLoaderVisible = PassthroughSubject<Bool, Never>();
    var urlApp = "-----//-----";
    var urlPreload = "-----//-----";
}
