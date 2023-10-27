//
//  JSUserScripts.swift
//  extreme-look-ios
//
//  Created by Влад Важенин on 09.01.2023.
//

import Foundation
let setPlatform = "window.platform = 'ios';"
let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
let getVersion = "app.methods.getVersionApp(false," + v + ")"
let setPushToken = "setPushToken('" + token + "')"
let setVersionApp = "setVersionApp(" + v + ")"
