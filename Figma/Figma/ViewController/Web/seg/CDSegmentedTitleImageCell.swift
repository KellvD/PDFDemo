//
//  CDSegmentedTitleImageCell.swift
//  Figma
//
//  Created by dong chang on 2024/1/25.
//

import UIKit
import JXSegmentedView
open class CDSegmentedTitleImageCell: JXSegmentedBaseCell {
    public let titleLabel = UILabel()
    //    public let maskTitleLabel = UILabel()
    //    public let titleMaskLayer = CALayer()
    //    public let maskTitleMaskLayer = CALayer()
    
    open override func commonInit() {
        super.commonInit()
        
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        //        maskTitleLabel.textAlignment = .center
        //        maskTitleLabel.isHidden = true
        //        contentView.addSubview(maskTitleLabel)
        //
        //        titleMaskLayer.backgroundColor = UIColor.red.cgColor
        //        titleMaskLayer.cornerRadius = 4
        //        titleMaskLayer.borderWidth = 1
        //        titleMaskLayer.borderColor = UIColor.customBlack.cgColor
        //
        //        maskTitleMaskLayer.backgroundColor = UIColor.red.cgColor
        //        maskTitleLabel.layer.mask = maskTitleMaskLayer
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        //为什么使用`sizeThatFits`，而不用`sizeToFit`呢？在numberOfLines大于0的时候，cell进行重用的时候通过`sizeToFit`，label设置成错误的size。至于原因我用尽毕生所学，没有找到为什么。但是用`sizeThatFits`可以规避掉这个问题。
        let labelSize = titleLabel.sizeThatFits(self.contentView.bounds.size)
        
        let width = max(labelSize.width, 20)
        let labelBounds = CGRect(x: 0, y: 0, width: min(width, 45), height:max(labelSize.height, 20))
        titleLabel.bounds = labelBounds
        titleLabel.center = contentView.center
        titleLabel.layer.cornerRadius = 4
        titleLabel.layer.borderWidth = 1
    
    }
    
    open override func reloadData(itemModel: JXSegmentedBaseItemModel, selectedType: JXSegmentedViewItemSelectedType) {
        super.reloadData(itemModel: itemModel, selectedType: selectedType )
        
        guard let myItemModel = itemModel as? JXSegmentedTitleItemModel else {
            return
        }
        
        titleLabel.numberOfLines = 1
        
        if myItemModel.isSelected {
            titleLabel.font = myItemModel.titleSelectedFont
            titleLabel.textColor = myItemModel.titleSelectedColor
            titleLabel.layer.borderColor = myItemModel.titleSelectedColor.cgColor
        }else {
            titleLabel.font = myItemModel.titleNormalFont
            titleLabel.textColor = myItemModel.titleNormalColor
            titleLabel.layer.borderColor = myItemModel.titleNormalColor.cgColor
            
        }
        let title = myItemModel.title ?? ""
        let attriText = NSMutableAttributedString(string: title)
        if myItemModel.isTitleStrokeWidthEnabled {
            if myItemModel.isSelectedAnimable && canStartSelectedAnimation(itemModel: itemModel, selectedType: selectedType) {
                //允许动画且当前是点击的
                let titleStrokeWidthClosure = preferredTitleStrokeWidthAnimateClosure(itemModel: myItemModel, attriText: attriText)
                appendSelectedAnimationClosure(closure: titleStrokeWidthClosure)
            }else {
                attriText.addAttributes([NSAttributedString.Key.strokeWidth: myItemModel.titleCurrentStrokeWidth], range: NSRange(location: 0, length: title.count))
                titleLabel.attributedText = attriText
                //                maskTitleLabel.attributedText = attriText
            }
        }else {
            titleLabel.attributedText = attriText
            //            maskTitleLabel.attributedText = attriText
        }
        titleLabel.layer.mask = nil
        if myItemModel.isSelectedAnimable && canStartSelectedAnimation(itemModel: itemModel, selectedType: selectedType) {
            //允许动画且当前是点击的
            let titleColorClosure = preferredTitleColorAnimateClosure(itemModel: myItemModel)
            appendSelectedAnimationClosure(closure: titleColorClosure)
        }else {
            titleLabel.textColor = myItemModel.titleCurrentColor
            titleLabel.layer.borderColor = myItemModel.titleCurrentColor.cgColor

            
        }
        
        startSelectedAnimationIfNeeded(itemModel: itemModel, selectedType: selectedType)
        
        setNeedsLayout()
        
    }

        public func preferredTitleZoomAnimateClosure(itemModel: JXSegmentedTitleItemModel, baseScale: CGFloat) -> JXSegmentedCellSelectedAnimationClosure {
        return {[weak self] (percnet) in
            if itemModel.isSelected {
                //将要选中，scale从小到大插值渐变
                itemModel.titleCurrentZoomScale = JXSegmentedViewTool.interpolate(from: itemModel.titleNormalZoomScale, to: itemModel.titleSelectedZoomScale, percent: percnet)
            }else {
                //将要取消选中，scale从大到小插值渐变
                itemModel.titleCurrentZoomScale = JXSegmentedViewTool.interpolate(from: itemModel.titleSelectedZoomScale, to:itemModel.titleNormalZoomScale , percent: percnet)
            }
            let currentTransform = CGAffineTransform(scaleX: baseScale*itemModel.titleCurrentZoomScale, y: baseScale*itemModel.titleCurrentZoomScale)
            self?.titleLabel.transform = currentTransform
//            self?.maskTitleLabel.transform = currentTransform
        }
    }

        func preferredTitleStrokeWidthAnimateClosure(itemModel: JXSegmentedTitleItemModel, attriText: NSMutableAttributedString) -> JXSegmentedCellSelectedAnimationClosure{
            return {[weak self] (percent) in
                if itemModel.isSelected {
                    //将要选中，StrokeWidth从小到大插值渐变
                    itemModel.titleCurrentStrokeWidth = JXSegmentedViewTool.interpolate(from: itemModel.titleNormalStrokeWidth, to: itemModel.titleSelectedStrokeWidth, percent: percent)
                }else {
                    //将要取消选中，StrokeWidth从大到小插值渐变
                    itemModel.titleCurrentStrokeWidth = JXSegmentedViewTool.interpolate(from: itemModel.titleSelectedStrokeWidth, to:itemModel.titleNormalStrokeWidth , percent: percent)
                }
                attriText.addAttributes([NSAttributedString.Key.strokeWidth: itemModel.titleCurrentStrokeWidth], range: NSRange(location: 0, length: attriText.string.count))
                self?.titleLabel.attributedText = attriText
                //            self?.maskTitleLabel.attributedText = attriText
            }
        }

    func preferredTitleColorAnimateClosure(itemModel: JXSegmentedTitleItemModel) -> JXSegmentedCellSelectedAnimationClosure {
        return {[weak self] (percent) in
            if itemModel.isSelected {
                //将要选中，textColor从titleNormalColor到titleSelectedColor插值渐变
                itemModel.titleCurrentColor = JXSegmentedViewTool.interpolateThemeColor(from: itemModel.titleNormalColor, to: itemModel.titleSelectedColor, percent: percent)
            }else {
                //将要取消选中，textColor从titleSelectedColor到titleNormalColor插值渐变
                itemModel.titleCurrentColor = JXSegmentedViewTool.interpolateThemeColor(from: itemModel.titleSelectedColor, to: itemModel.titleNormalColor, percent: percent)
            }
            self?.titleLabel.textColor = itemModel.titleCurrentColor
            self?.titleLabel.layer.borderColor = itemModel.titleCurrentColor.cgColor

//            self?.titleMaskLayer.borderColor = itemModel.titleCurrentColor.cgColor

        }
    }
}
