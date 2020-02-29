//
//  LoadingIndicatorView.swift
//  groov
//
//  Created by Kyujin Kim on 2020/02/22.
//  Copyright © 2020 Mildwhale. All rights reserved.
//

import UIKit

final class LoadingIndicatorView: BaseView {
    private let activityIndicatorView = UIActivityIndicatorView(style: .white)
    
    override init(frame: CGRect) {
        let width = UIScreen.main.bounds.width
        let height = Constants.Layout.SearchList.heightForSuggest
        
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(activityIndicatorView)
    }
        
    override func layout() {
        super.layout()
        
        activityIndicatorView.center = center
    }
        
    override func style() {
        super.style()
        
        backgroundColor = GRVColor.backgroundColor
        
        activityIndicatorView.startAnimating()
    }
}
