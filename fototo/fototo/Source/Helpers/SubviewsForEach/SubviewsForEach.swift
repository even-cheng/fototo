//
//  SubviewsForEach.swift
//  DemoExpandingCollection
//
//  Created by Even_cheng on 26/09/19.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import UIKit

protocol SubviewsForEach {
    func subviewsForEach(_ f: (UIView) -> Void)
}

extension SubviewsForEach where Self: UIView {

    func subviewsForEach(_ f: (UIView) -> Void) {
        forEachView(self, f: f)
    }

    fileprivate func forEachView(_ view: UIView, f: (UIView) -> Void) {
        view.subviews.forEach {
            f($0)

            if $0.subviews.count > 0 {
                forEachView($0, f: f)
            }
        }
    }
}

extension UIView: SubviewsForEach {}
