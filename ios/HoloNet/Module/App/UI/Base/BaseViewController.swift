//
//  BaseViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 15/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController, Themeable {
    let toolbox: Toolbox
    
    private(set) var theme: Theme?
    private(set) var disposeBag: DisposeBag
    
    init(toolbox: Toolbox, nibName: String?, bundle: Bundle?) {
        self.toolbox = toolbox
        self.disposeBag = DisposeBag()
        super.init(nibName: nibName, bundle: bundle)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    // MARK: -
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.toolbox
            .theme
            .drive(onNext: self.apply(theme:))
            .disposed(by: self.disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disposeBag = DisposeBag()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.theme?.statusBarStyle ?? .default
    }
    
    func apply(theme: Theme) {
        guard self.theme != theme else { return }
        
        self.theme = theme
        self.setNeedsStatusBarAppearanceUpdate()
    }
}
