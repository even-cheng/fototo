//
//  DemoTableViewController.swift
//  TestCollectionView
//
//  Created by Even_cheng on 24/09/19.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import UIKit

class DemoTableViewController: ExpandingTableViewController {

    open var product: Product?
    
    lazy var commentInputView: ECInputView? = {
        
        let inputView = ECInputView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height-64))
        inputView.delegate = self as ECInputViewDelegate
        return inputView
    }()
    
    fileprivate var scrollOffsetY: CGFloat = 0
    var backgroundImage : Image? {
        didSet {
            tableView.backgroundView = UIImageView(image: backgroundImage)
        }
    }
    lazy var commentButton: UIButton = {
        
        let comment = UIButton.init(frame: CGRect.init(x: kWindowBounds.size.width-100, y: kWindowBounds.size.height-100, width: 80, height: 80));
        comment.addTarget(self, action: #selector(commentAction), for: UIControl.Event.touchUpInside)
        comment.setImage(UIImage.init(named: "comment"), for: UIControl.State.normal)
        comment.layer.shadowColor = UIColor.gray.cgColor
        comment.layer.shadowOffset = CGSize(width: 0, height: 0)
        comment.layer.shadowOpacity = 0.35
        comment.layer.shadowRadius = 3

        return comment
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.register(UINib.init(nibName: "ProductCommentCell", bundle: nil), forCellReuseIdentifier: "ProductCommentCell")
        tableView.register(UINib.init(nibName: "ProductInfoCell", bundle: nil), forCellReuseIdentifier: "ProductInfoCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.delegate?.window??.addSubview(commentButton)
        
        addPopToComment()
        tableView.reloadData()
    }
    
    private func addPopToComment() {
        let animation =  CAKeyframeAnimation.init(keyPath: "position.y")
        let finalY = kWindowBounds.size.height-100
        animation.values = [finalY+100,finalY,finalY-20,finalY+10,finalY]
        animation.duration  = 0.5
        animation.autoreverses = false
        animation.fillMode = .forwards
        animation.repeatCount = 1
        //动画速度变化
        animation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false;
        commentButton.layer.add(animation, forKey: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        commentButton.removeFromSuperview()
    }
    
    @IBAction func likeAction(_ sender: DOFavoriteButton) {
        
        guard let product = product else {
            return;
        }
        
        var count = product.liked_users?.count ?? 0
        if sender.isSelected {
            FTAPI.unLike(product)
            count -= 1
            sender.deselect()
        } else {
            FTAPI.like(product)
            count += 1
            sender.select()
        }
        if count <= 0 {
            count = 0
        }
    }
    
    @objc func commentAction() {
        
        kWindow.addSubview(commentInputView!)
        commentInputView?.inputViewShow()
    }
}

// MARK: Helpers

extension DemoTableViewController {

    fileprivate func configureNavBar() {
        navigationItem.rightBarButtonItem?.image = navigationItem.rightBarButtonItem?.image!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
    }
}

// MARK: Actions

extension DemoTableViewController {

    @IBAction func backButtonHandler(_: AnyObject) {
        // buttonAnimation
        let viewControllers: [DemoViewController?] = navigationController?.viewControllers.map { $0 as? DemoViewController } ?? []

        for viewController in viewControllers {
            if let rightButton = viewController?.navigationItem.rightBarButtonItem as? AnimatingBarButton {
                rightButton.animationSelected(false)
            }
        }
        popTransitionAnimation()
    }
}

// MARK: UIScrollViewDelegate

extension DemoTableViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -100 , let navigationController = navigationController {
            // buttonAnimation
            for case let viewController as DemoViewController in navigationController.viewControllers {
                if case let rightButton as AnimatingBarButton = viewController.navigationItem.rightBarButtonItem {
                    rightButton.animationSelected(false)
                }
            }
            popTransitionAnimation()
        }
        scrollOffsetY = scrollView.contentOffset.y
    }
}

extension DemoTableViewController :ECInputViewDelegate{
    
    func sendText(_ text: String!) {

        guard text.count > 0, product != nil else {return}
        commentInputView?.inputViewHiden()
        FTAPI.addComment(to: product!, content: text!)
    }
}

extension DemoTableViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.product?.comments!.count)!+1
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductInfoCell", for: indexPath) as! ProductInfoCell
            cell.product = self.product
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCommentCell", for: indexPath) as! ProductCommentCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 125
        }
        return 120
    }
    
}
