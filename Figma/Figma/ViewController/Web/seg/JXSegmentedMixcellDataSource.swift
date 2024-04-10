//
//  JXSegmentedMixcellDataSource.swift
//  JXSegmentedView
//
//  Created by jiaxin on 2019/1/22.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit
import JXSegmentedView

/// 该示例主要用于展示cell的自定义组合。就像使用UITableView一样，注册不同的cell class，为不同的cell赋值。
/// 当你的需求需要处理不同类型的cell时，可以参考这里的逻辑。但是数据源这一块就需要你自己处理了。
/// 多种cell混用时，不建议处理cell之间元素的过渡。所以该示例也没有处理滚动过渡。
class JXSegmentedMixcellDataSource: JXSegmentedBaseDataSource {

    override func reloadData(selectedIndex: Int) {
        super.reloadData(selectedIndex: selectedIndex)
        let count = CDSqlManager.shared.queryWebPageCount()

        let titleModel = JXSegmentedTitleItemModel()
        titleModel.title = "\(count)"
        titleModel.titleNormalColor = UIColor(191, 197, 206)
        titleModel.titleSelectedFont = .regular(12)
        titleModel.titleSelectedColor = .white
        titleModel.titleNormalFont = .regular(12)
        titleModel.textWidth = 20.0
       dataSource.append(titleModel)

        let titleImageModel = JXSegmentedTitleImageItemModel()
        titleImageModel.normalImageInfo = "历史记录-未点"
        titleImageModel.selectedImageInfo = "历史记录-点"
        titleImageModel.isSelectedAnimable = true

        titleImageModel.imageSize = CGSize(width: 20, height: 20)
        dataSource.append(titleImageModel)

        for (index, model) in (dataSource as! [JXSegmentedTitleItemModel]).enumerated() {
            if index == selectedIndex {
                model.isSelected = true
                model.titleCurrentColor = model.titleSelectedColor
                break
            }
        }
    }

    override func preferredSegmentedView(_ segmentedView: JXSegmentedView, widthForItemAt index: Int) -> CGFloat {
        return 56
    }

    //MARK: - JXSegmentedViewDataSource
    override func registerCellClass(in segmentedView: JXSegmentedView) {
        segmentedView.collectionView.register(CDSegmentedTitleImageCell.self, forCellWithReuseIdentifier: "titleCell")
        segmentedView.collectionView.register(JXSegmentedTitleImageCell.self, forCellWithReuseIdentifier: "titleImageCell")
    }

    override func segmentedView(_ segmentedView: JXSegmentedView, cellForItemAt index: Int) -> JXSegmentedBaseCell {
        var cell:JXSegmentedBaseCell?
        if dataSource[index] is JXSegmentedTitleImageItemModel {
            cell = segmentedView.dequeueReusableCell(withReuseIdentifier: "titleImageCell", at: index)
        }else if dataSource[index] is JXSegmentedTitleItemModel {
            cell = segmentedView.dequeueReusableCell(withReuseIdentifier: "titleCell", at: index)
        }
        return cell!
    }

    //针对不同的cell处理选中态和未选中态的刷新
    override func refreshItemModel(_ segmentedView: JXSegmentedView, currentSelectedItemModel: JXSegmentedBaseItemModel, willSelectedItemModel: JXSegmentedBaseItemModel, selectedType: JXSegmentedViewItemSelectedType) {
        super.refreshItemModel(segmentedView, currentSelectedItemModel: currentSelectedItemModel, willSelectedItemModel: willSelectedItemModel, selectedType: selectedType)

        guard let myCurrentSelectedItemModel = currentSelectedItemModel as? JXSegmentedTitleItemModel,
              let myWilltSelectedItemModel = willSelectedItemModel as? JXSegmentedTitleItemModel else {
            return
        }

        myCurrentSelectedItemModel.titleCurrentColor = myCurrentSelectedItemModel.titleNormalColor

        myWilltSelectedItemModel.titleCurrentColor = myWilltSelectedItemModel.titleSelectedColor
    }
}
