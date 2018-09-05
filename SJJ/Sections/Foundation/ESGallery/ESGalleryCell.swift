//
//  ESGalleryCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/31.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
import Kingfisher

protocol ESGalleryCellDelegate: class {
    func setUpImgView(_ imgView: UIImageView,
                      _ section: Int,
                      _ index: Int,
                      complete: @escaping (_ section: Int, _ index: Int) -> Void)
    func tapSingleDid()
    func tapDoubleDid()
}

class ESGalleryCell: UICollectionViewCell, UIScrollViewDelegate {

    weak var delegate: ESGalleryCellDelegate?
    private var section = 0
    private var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.black
        
        addSubviews()
    }
    
    func updateCell(_ section: Int, _ row: Int) {
        self.section = section
        index = row
        
        delegate?.setUpImgView(imgView, section, row, complete: { (s, i) in
            DispatchQueue.main.async {
                if self.section == s && self.index == i {
                    self.resetSize()
                }
            }
        })
    }
    
    func resetSize(){
        //scrollView重置，不缩放
        scrollView.frame = contentView.bounds
        scrollView.zoomScale = 1.0
        //imageView重置
        if let image = imgView.image {
            //设置imageView的尺寸确保一屏能显示的下
            imgView.frame.size = scaleSize(size: image.size)
            //imageView居中
            imgView.center = scrollView.center
        }
    }
    
    //视图布局改变时（横竖屏切换时cell尺寸也会变化）
    override func layoutSubviews() {
        super.layoutSubviews()
        //重置单元格内元素尺寸
        resetSize()
    }
    
    //获取imageView的缩放尺寸（确保首次显示是可以完整显示整张图片）
    func scaleSize(size:CGSize) -> CGSize {
        let width = size.width
        let height = size.height
        let widthRatio = width/UIScreen.main.bounds.width
        let heightRatio = height/UIScreen.main.bounds.height
        let ratio = max(heightRatio, widthRatio)
        return CGSize(width: width/ratio, height: height/ratio)
    }
    
    //图片单击事件响应
    @objc func tapSingleDid(_ ges:UITapGestureRecognizer){
        delegate?.tapSingleDid()
    }
    
    //图片双击事件响应
    @objc func tapDoubleDid(_ ges:UITapGestureRecognizer){
        delegate?.tapDoubleDid()
        //缩放视图
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            if self.scrollView.zoomScale == 1.0 {
                self.scrollView.zoomScale = 3.0
            }else{
                self.scrollView.zoomScale = 1.0
            }
        }, completion: nil)
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var centerX = scrollView.center.x
        var centerY = scrollView.center.y
        centerX = scrollView.contentSize.width > scrollView.frame.size.width ?
            scrollView.contentSize.width / 2 : centerX
        centerY = scrollView.contentSize.height > scrollView.frame.size.height ?
            scrollView.contentSize.height / 2 : centerY
        imgView.center = CGPoint(x: centerX, y: centerY)
    }
    
    // MARK: - Private
    private func addSubviews() {
        contentView.addSubview(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: contentView.bounds)
        view.delegate = self
        view.maximumZoomScale = 3.0
        view.minimumZoomScale = 1.0
        let tapSingle = UITapGestureRecognizer(target:self,
                                               action:#selector(tapSingleDid))
        view.addGestureRecognizer(tapSingle)
        view.addSubview(imgView)
        return view
    }()
    
    private lazy var imgView: UIImageView = {
        let view = UIImageView(frame: contentView.bounds)
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleAspectFit
        let tapSingle = UITapGestureRecognizer(target:self,
                                               action:#selector(tapSingleDid))
        tapSingle.numberOfTapsRequired = 1
        tapSingle.numberOfTouchesRequired = 1

        let tapDouble = UITapGestureRecognizer(target:self,
                                               action:#selector(tapDoubleDid(_:)))
        tapDouble.numberOfTapsRequired = 2
        tapDouble.numberOfTouchesRequired = 1

        tapSingle.require(toFail: tapDouble)
        view.addGestureRecognizer(tapSingle)
        view.addGestureRecognizer(tapDouble)
        return view
    }()
}
