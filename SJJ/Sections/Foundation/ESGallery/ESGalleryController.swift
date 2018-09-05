//
//  ESGalleryController.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/31.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
import Kingfisher

protocol ESGalleryControllerDelegate {
    func deleteImages(index: Int)
}

public class ESGalleryController: UIViewController, ESGalleryNavigationBarDelegate,  ESGalleryViewDelegate, ESGalleryCellDelegate {
    
    private var images = [Any?]()
    private var currentIndex = 0
    
    /// 初始化方法
    ///
    /// - Parameter images: UIImage / String(url)
    init(images: [Any?]) {
        super.init(nibName: nil, bundle: nil)
        self.images = images
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        self.view.backgroundColor = UIColor.black
        
        view.addSubview(mainView)
        view.addSubview(navibar)
        mainView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        navibar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.topLayoutGuide.snp.top)
            make.height.equalTo(STATUSBAR_HEIGHT + 44)
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dissMissBar()
    }
    
    // MARK: - ESGalleryNavigationBarDelegate
    func popAction() {
        navigationController?.popViewController(animated: true)
    }
    
    func deleteAction() {
        print("delete")
        images.remove(at: currentIndex)
        mainView.deleteItem(index: currentIndex)
    }
    
    private func dissMissBar() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.navibar.alpha = 0.0
        }) { (sucess) in
        }
        
        let animation = ESSpringAnimation(fromValue: NSNumber(value:1.0), toValue: NSNumber(value: 0.0), keyPath: "transform.translation.y")
        animation.damping = 30
        animation.stiffness = 14
        animation.mass = 0
        animation.duration = 0.5
        navibar.layer.add(animation, forKey: animation.keyPath)
        navibar.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
    }
    
    private func showBar() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.navibar.alpha = 1.0
        }) { (sucess) in
        }
        
        let animation = ESSpringAnimation(fromValue: NSNumber(value:0.0), toValue: NSNumber(value: 1.0), keyPath: "transform.translation.y")
        animation.damping = 30
        animation.stiffness = 14
        animation.mass = 0
        animation.duration = 0.5
        navibar.layer.add(animation, forKey: animation.keyPath)
        navibar.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
    }
    
    // MARK: - ESGalleryViewDelegate
    func getNums(_ section: Int) -> Int {
        return images.count
    }
    
    func disPlaying(index: Int) {
        currentIndex = index
    }
    
    // MARK: - ESGalleryCellDelegate
    func setUpImgView(_ imgView: UIImageView,
                      _ section: Int,
                      _ index: Int,
                      complete: @escaping (_ section: Int, _ index: Int) -> Void) {
        if images.count <= index {
            return
        }
        let img = images[index]
        
        if let image = img as? UIImage {// 如果为图片
            imgView.image = image
        } else if let imgUrl = img as? String {// 如果为图片url
            let url = URL(string: imgUrl)
            let options: KingfisherOptionsInfo = [.transition(.fade(1.0))]
            imgView.kf.setImage(with: url,
                                placeholder: ESPackageAsserts.bundleImage(named: "default_case"),
                                options: options,
                                progressBlock: nil,
                                completionHandler: {(image, error, cacheType, imageURL) in
                                    complete(section, index)
            })
        }
    }
    
    func tapSingleDid() {
        if navibar.alpha <= 0.0 {
            showBar()
        } else {
            dissMissBar()
        }
    }
    
    func tapDoubleDid() {
        if navibar.alpha > 0.0 {
            dissMissBar()
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var navibar: ESGalleryNavigationBar = {
        let bar = ESGalleryNavigationBar(delegate: self)
        return bar
    }()
    
    private lazy var mainView: ESGalleryView = {
        let view = ESGalleryView(delegate: self)
        return view
    }()
    
}
