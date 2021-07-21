//
//  StackViewController.swift
//  PLKit
//
//  Created by macmini-jym on 2021/7/20.
//  Copyright © 2021 Plumk. All rights reserved.
//

import UIKit
import SnapKit

class StackViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "StackView"
        
        self.createPLStackView()
        self.createUIStackView()
    }
    
    func createPLStackView() {
        
        
        let stackView = PLStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        stackView.backgroundColor = .black
        self.view.addSubview(stackView)
        
        
        stackView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().inset(150)
            maker.top.equalToSuperview().offset(300)
            maker.width.equalTo(100)
            maker.height.equalTo(300)
        }
        
        
        let view1 = UIView()
        view1.backgroundColor = .red
        stackView.addArrangedSubview(view1, afterSpacing: 10)
        
        let view2 = UIView()
        view2.backgroundColor = .red
        stackView.addArrangedSubview(view2, afterSpacing: 10)
        
        let view3 = UIView()
        view3.backgroundColor = .red
        stackView.addArrangedSubview(view3, afterSpacing: 10)

        view1.snp.makeConstraints { maker in
            maker.width.equalTo(60).priority(.low)
            maker.height.equalTo(60).priority(.low)
        }
        
        view2.snp.makeConstraints { maker in
            maker.width.equalTo(30).priority(.low)
            maker.height.equalTo(30).priority(.low)
        }
        
        view3.snp.makeConstraints { maker in
            maker.width.equalTo(15).priority(.low)
            maker.height.equalTo(15).priority(.low)
        }
    }
    
    func createUIStackView() {
        
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        
        stackView.backgroundColor = .black
        self.view.addSubview(stackView)
        
        
        stackView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().inset(20)
            maker.top.equalToSuperview().offset(300)
            maker.width.equalTo(100)
            maker.height.equalTo(300)
        }
        
        
        let view1 = UIView()
        view1.backgroundColor = .red

        
        let view2 = UIView()
        view2.backgroundColor = .red
        
        let view3 = UIView()
        view3.backgroundColor = .red
        
        
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(view2)
        stackView.addArrangedSubview(view3)
        

        view1.snp.makeConstraints { maker in
            maker.width.equalTo(60).priority(.low)
            maker.height.equalTo(60).priority(.low)
        }
        
        view2.snp.makeConstraints { maker in
            maker.width.equalTo(30).priority(.low)
            maker.height.equalTo(30).priority(.low)
        }
        
        view3.snp.makeConstraints { maker in
            maker.width.equalTo(15).priority(.low)
            maker.height.equalTo(15).priority(.low)
        }
    }
}
