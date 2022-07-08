//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import UIKit
import WebKit

open class WebViewController: BaseViewController {
    
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.allowsBackForwardNavigationGestures = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var request: URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        return URLRequest(url: url)
    }
    
    private var urlString: String
    
    public init(urlString: String) {
        self.urlString = urlString

        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        guard let request = request else { return }
        
        setupWebView()
        webView.load(request)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showTopNavBar()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideTopNavBar()
    }
    
    public func setupWebView() {
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
}
