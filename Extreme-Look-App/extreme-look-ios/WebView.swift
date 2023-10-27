//
//  WebView.swift
//  extreme-look-ios
//
//  Created by Влад Важенин on 09.01.2023.
//

import Foundation
import SwiftUI
import Combine
import WebKit
import UIKit

struct WebView: UIViewRepresentable {
    
    var type: URLType
    var preload: Bool
    var url: String?
    @ObservedObject var viewModel: ViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        
        let configuration = WKWebViewConfiguration()

        configuration.preferences = preferences
        configuration.userContentController.add(context.coordinator, contentWorld: .page, name: "iOS")
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.isScrollEnabled = false
        webView.customUserAgent = "extreme-look-apple-vlad"
        
        return webView
    
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let urlValue = url  {
            if let requestUrl = URL(string: urlValue) {
                webView.load(URLRequest(url: requestUrl))
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var webViewNavigationSubscriber: AnyCancellable? = nil
        
        init(_ webView: WebView) {
            self.parent = webView
        }
        deinit {
            webViewNavigationSubscriber?.cancel()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            //print("EX_didFinish")
            if !self.parent.preload{
                self.parent.viewModel.isLoaderVisible.send(false)
                self.parent.viewModel.loadApp = true
                webView.evaluateJavaScript(setPlatform, in: nil, in: .page)
                webView.evaluateJavaScript(getVersion, in: nil, in: .page)
                webView.evaluateJavaScript(setPushToken, in: nil, in: .page)
                webView.evaluateJavaScript(setVersionApp, in: nil, in: .page)
                if(ExtremeLook.initWebView){
                    ExtremeLook.webView = webView;
                    ExtremeLook.initWebView = false;
                }
                if(ExtremeLook.openNotifi){
                    ExtremeLook.openNotifi = false;
                    ExtremeLook.webView.load(URLRequest(url: URL(string: ExtremeLook.notifiURL)!))
                }
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            if !self.parent.preload{
                //print("EX_didStartProvisionalNavigation")
                self.parent.viewModel.isLoaderVisible.send(true)
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            //print("didFailProvisionalNavigation")
            self.parent.viewModel.isLoaderVisible.send(false)
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            //print("EX_didCommit")
            if !self.parent.preload{
                self.parent.viewModel.isLoaderVisible.send(true)
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            //print("EX_didFail")
            self.parent.viewModel.isLoaderVisible.send(false)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
            //print("EX_decidePolicyFor")
            decisionHandler(.allow, preferences)
        }
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            //print("EX_didReceiveServerRedirectForProvisionalNavigation")
        }
        
        func webView(_ webView: WKWebView,
                     runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void){

            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            completionHandler();
        }
        
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            //print("EX_webViewWebContentProcessDidTerminate")
            self.parent.viewModel.isLoaderVisible.send(false)
        }
        
        func openLink(link: String){
            guard let url = URL(string: link) else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
        func shareLink(link: String){
            UIPasteboard.general.string = link
        }
        func openMailto(link: URL){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(link)
            } else {
                UIApplication.shared.openURL(link)
            }
        }
        func openTel(link: URL){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(link)
            } else {
                UIApplication.shared.openURL(link)
            }
        }
    }
}

extension WebView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "iOS"{
            if let data = message.body as? NSDictionary{
                if let action: String = data["action"] as? String{
                    if action == "shareLink"{
                        if let link: String = data["link"] as? String{
                            shareLink(link: link)
                        }
                    }
                    if action == "openLink"{
                        if let link: String = data["link"] as? String{
                            openLink(link: link)
                        }
                    }
                    if action == "openMailto"{
                        if let link: String = data["link"] as? String{
                            openMailto(link: (URL(string: link)!))
                        }
                    }
                    if action == "openTel"{
                        if let link: String = data["link"] as? String{
                            openTel(link: URL(string: link)!)
                        }
                    }
                }
            }
        }
    }
}
