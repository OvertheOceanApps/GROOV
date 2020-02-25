//
//  LoadingIndicatorView.swift
//  groov
//
//  Created by Kyujin Kim on 2020/02/22.
//  Copyright © 2020 Mildwhale. All rights reserved.
//

import UIKit

final class LoadingIndicatorView: UIView {
    private let activityIndicatorView = UIActivityIndicatorView(style: .white)
    
    override init(frame: CGRect) {
        let width = UIScreen.main.bounds.width
        let height = Constants.Layout.SearchList.heightForSuggest
        
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    func initialize() {
        addSubview()
        layout()
        style()
    }
    
    func addSubview() {
        addSubview(activityIndicatorView)
    }
    
    func layout() {
        activityIndicatorView.center = center
    }
    
    func style() {
        backgroundColor = GRVColor.backgroundColor
        
        activityIndicatorView.startAnimating()
    }
}
