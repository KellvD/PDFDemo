//
//  CDWaterToolView.swift
//  PDF
//
//  Created by dong chang on 2024/3/23.
//

import UIKit

class CDWaterToolView: UIView,UICollectionViewDelegate,UICollectionViewDataSource {

    
    @IBOutlet weak var colorsView: UICollectionView!
    
    @IBOutlet weak var fontsView: UICollectionView!
    
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var cannelBtn: UIButton!
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var sizeValueLabel: UILabel!
    
    @IBOutlet weak var opacityLabel: UILabel!
    
    @IBOutlet weak var opacityValueLabel: UILabel!
    @IBOutlet weak var textfiled: UITextField!
    @IBOutlet weak var countLabell: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    var colors: [UIColor] = [.red,.white,.black,.gray]
    var fonts: [UIFont] = []

    var actionHandler: ((UIColor?)->Void)?
    private var selectColorIndex = 0
    private var selectFontIndex = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame = CGRect(x: 0, y: CDViewHeight - 240, width: CDSCREEN_WIDTH, height: 240)
        self.backgroundColor = .white
        self.cannelBtn.layer.cornerRadius = 16
        cannelBtn.backgroundColor = UIColor(red: 0.918, green: 0.929, blue: 0.957, alpha: 1)
        cannelBtn.setTitle("Cannel".localize(), for: .normal)
        cannelBtn.setTitleColor(UIColor(red: 0.498, green: 0.537, blue: 0.631, alpha: 1), for: .normal)
        cannelBtn.titleLabel?.font = .helvBold(12)
        
        doneBtn.layer.cornerRadius = 16
        doneBtn.backgroundColor = UIColor(red: 0.255, green: 0.443, blue: 1, alpha: 1)
        doneBtn.setTitle("Done".localize(), for: .normal)
        doneBtn.setTitleColor(UIColor(red: 0.498, green: 0.537, blue: 0.631, alpha: 1), for: .normal)
        doneBtn.titleLabel?.font = .helvBold(12)
        
        countLabell.textColor = .white
        countLabell.text = "1/5"
        countLabell.backgroundColor = UIColor(red: 0.498, green: 0.537, blue: 0.631, alpha: 1)
        countLabell.layer.cornerRadius = 16
        countLabell.font = .helvBold(12)
        
        sizeLabel.font = .regular(14)
        sizeLabel.textColor = .black
        sizeLabel.text = "Size".localize()
        
        sizeValueLabel.font = .regular(14)
        sizeValueLabel.textColor = .black
        sizeValueLabel.text = "30"
        
        opacityLabel.font = .regular(14)
        opacityLabel.textColor = .black
        opacityLabel.text = "Opacity".localize()

        
        opacityValueLabel.font = .regular(14)
        opacityValueLabel.textColor = .black
        opacityValueLabel.text = "30"

        
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        textfiled.leftView = leftView
        textfiled.leftViewMode = .always
        textfiled.layer.backgroundColor = UIColor(red: 0.918, green: 0.929, blue: 0.957, alpha: 1).cgColor
        textfiled.layer.cornerRadius = 28
        textfiled.layer.borderWidth = 1
        textfiled.layer.borderColor = UIColor(red: 0.754, green: 0.787, blue: 0.864, alpha: 1).cgColor
        textfiled.placeholder = "Enter your text…".localize()
        
        colorsView.delegate = self
        colorsView.dataSource = self
        colorsView.register(CDColorCell.self, forCellWithReuseIdentifier: "CDColorCell")
        colorsView.reloadData()
        
        fontsView.delegate = self
        fontsView.dataSource = self
        fontsView.register(CDFontsCell.self, forCellWithReuseIdentifier: "CDFontsCell")
        fontsView.reloadData()
    }
    
    @IBAction func onCannelAction(_ sender: Any) {
    }
    
    @IBAction func onDoneAction(_ sender: Any) {
    }
    
    @IBAction func onSizeValueChange(_ sender: Any) {
    }
    
    @IBAction func onOpacityValueChange(_ sender: Any) {
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colorsView {
            return colors.count
        }
        return fonts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == colorsView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDColorCell", for: indexPath) as! CDColorCell
            let model = colors[indexPath.item]
            cell.view.backgroundColor = model
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDFontsCell", for: indexPath) as! CDFontsCell
            let model = fonts[indexPath.item]
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorsView {
            selectColorIndex = indexPath.item
        } else {
            selectFontIndex = indexPath.item
        }

    }

}

class CDColorCell: UICollectionViewCell {
    var view: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        view.layer.cornerRadius = frame.height/2.0
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CDFontsCell: UICollectionViewCell {
    var view: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        view.layer.cornerRadius = frame.height/2.0
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
