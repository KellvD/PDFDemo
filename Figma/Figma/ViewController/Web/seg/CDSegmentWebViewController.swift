//
//  CDSegmentWebViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/14.
//
import JXSegmentedView
import Foundation

class CDSegmentWebViewController: UIViewController {
    private var segmentedDataSource: JXSegmentedBaseDataSource?
    private let segmentedView = JXSegmentedView()
    private let totalItemWidth: CGFloat = 112

    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataSource = JXSegmentedMixcellDataSource()
        dataSource.itemWidth = totalItemWidth/CGFloat(2)
        dataSource.itemSpacing = 0
        segmentedDataSource = dataSource
        
        let indicator2 = JXSegmentedIndicatorBackgroundView()
        indicator2.indicatorHeight = 36
        indicator2.indicatorWidthIncrement = 0
        indicator2.indicatorColor = .customBlack
        
        segmentedView.frame = CGRect(x: 0, y: 0, width: totalItemWidth, height: 40)
        segmentedView.backgroundColor = UIColor(236, 240, 244)
        segmentedView.layer.masksToBounds = true
        segmentedView.layer.cornerRadius = 18
        segmentedView.dataSource = segmentedDataSource
        segmentedView.indicators = [indicator2]
        segmentedView.delegate = self
        navigationItem.titleView = segmentedView

        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
                
      
    }
    
    func didIndicatorPositionChanged() {
        
        segmentedView.reloadDataWithoutListContainer()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.hidesBottomBarWhenPushed = true
        //处于第一个item的时候，才允许屏幕边缘手势返回
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let count = CDSqlManager.shared.queryWebPageCount()
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedMixcellDataSource,
           let titleModel = titleDataSource.dataSource[0] as? JXSegmentedTitleItemModel {
            titleModel.title = "\(count)"
            segmentedView.reloadItem(at: 0)
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedView.frame = CGRect(x: 0, y: 0, width: totalItemWidth, height: 30)
        listContainerView.frame = view.bounds

    }
    
    lazy var prevc: CDWebPreviewViewController = {
        let vc = CDWebPreviewViewController()
        vc.naItem = navigationItem
        vc.backBlock = { [weak self] in
            guard let self = self else {
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
        return vc
    }()
    
    lazy var hisvc: CDHistoryViewController = {
        let vc = CDHistoryViewController()
        vc.naItem = navigationItem

        vc.backBlock = { [weak self] in
            guard let self = self else {
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
        return vc
    }()
    
    func createLeftButton() -> UIButton {
        
        let leftItemBtn = UIButton(type: .custom)
        leftItemBtn.contentHorizontalAlignment = .left
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftItemBtn)
        return leftItemBtn
    }
    
    func createRightButton() -> UIButton {
        let rightItemBtn = UIButton(type: .custom)
        rightItemBtn.contentHorizontalAlignment = .right
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightItemBtn)
        return rightItemBtn
    }
    
}

extension CDSegmentWebViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if index == 0 {
            let count = CDSqlManager.shared.queryWebPageCount()
            if let titleDataSource = segmentedView.dataSource as? JXSegmentedMixcellDataSource,
               let titleModel = titleDataSource.dataSource[0] as? JXSegmentedTitleItemModel {
                titleModel.title = "\(count)"
                segmentedView.reloadItem(at: index)
            }
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }
}

extension CDSegmentWebViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        
        if index == 0 {
            return self.prevc
        } else {
            return self.hisvc
        }
    }
}


extension CDHistoryViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

extension CDWebPreviewViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
