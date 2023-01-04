//
//  DiscoverTribesWkWebView.swift
//  sphinx
//
//  Created by James Carucci on 1/2/23.
//  Copyright © 2023 sphinx. All rights reserved.
//

import Foundation
import WebKit
import UIKit


protocol DiscoverTribesWVVCDelegate{
    func handleDeeplinkClick()
}

extension DashboardRootViewController : DiscoverTribesWVVCDelegate{
    func handleDeeplinkClick() {
        self.handleDeepLinksAndPush()
    }
    
    
}

class DiscoverTribesWebViewController : UIViewController{
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var tableView: UITableView!
    
    var discoverTribesTableViewDataSource : DiscoverTribeTableViewDataSource? = nil
    let urlString = "https://community.sphinx.chat/t"
    var rootViewController: RootViewController!
    //let urlString = "localhost:5000"
    var delegate: DiscoverTribesWVVCDelegate? = nil
    var shouldUseWebview = true
    
    
    
    static func instantiate(
        rootViewController: RootViewController
    ) -> DiscoverTribesWebViewController {
        let viewController = StoryboardScene.Welcome.discoverTribesWebViewController.instantiate()
        viewController.rootViewController = rootViewController
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(shouldUseWebview){
            loadDiscoverTribesWebView()
            //tableView.isHidden = true
        }
        else{
            configTableView()
            webView.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.configTableView()
    }
    
    func loadDiscoverTribesWebView(){
        if let link = URL(string:urlString){
            let request = URLRequest(url: link)
            webView.load(request)
            self.webView.navigationDelegate = self
        }
    }
    
    
    func configTableView(){
        _ = self.view
        discoverTribesTableViewDataSource = DiscoverTribeTableViewDataSource(tableView: tableView, vc: self)
        if let dataSource = discoverTribesTableViewDataSource{
            tableView.delegate = dataSource
            tableView.dataSource = dataSource
            tableView.reloadData()
        }
    }
}


extension DiscoverTribesWebViewController : WKNavigationDelegate{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
           if navigationAction.navigationType == WKNavigationType.linkActivated {
               print("link")
               print(navigationAction.request.url)
               if let url = navigationAction.request.url{
                   if DeepLinksHandlerHelper.storeLinkQueryFrom(url: url),
                      let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                       appDelegate.setInitialVC(launchingApp: false, deepLink: true)
                       self.navigationController?.popViewController(animated: true)
                   }
               }
               decisionHandler(WKNavigationActionPolicy.cancel)
               return
           }
           print("no link")
           decisionHandler(WKNavigationActionPolicy.allow)
    }
}