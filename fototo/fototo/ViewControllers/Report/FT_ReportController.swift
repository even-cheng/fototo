//
//  FT_ReportController.swift
//  fototo
//
//  Created by Even_cheng on 2019/10/29.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import Foundation

class FT_ReportController: UIViewController {
  
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var tipLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension FT_ReportController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        tipLabel.isHidden = true
        return true
    }
}
