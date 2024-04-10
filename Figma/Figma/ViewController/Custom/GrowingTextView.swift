//
//  GrowingTextView.swift
//  Figma
//
//  Created by dong chang on 2024/1/23.
//

import UIKit
import Foundation

protocol GrowingTextViewDelegate: UITextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat)
}


class GrowingTextView: UITextView {
    
    private var nextStepBtn: UIButton!
    private var lastStepBtn: UIButton!
    private var menuView: UIToolbar?
    private var manager: UndoManager!

    override open var text: String! {
        didSet { setNeedsDisplay() }
        
    }
    private var heightConstraint: NSLayoutConstraint?
    // Maximum length of text. 0 means no limit.
    @IBInspectable open var maxLength: Int = 0
    // Trim whige space and newline characters when end editing. Default is true
    @IBInspectable open var trimWhiteSpaceWhenEndEditing: Bool = true
    // Customization
    @IBInspectable open var minHeight: CGFloat = 0 {
        didSet { forceLayoutSubviews()}
    }
    @IBInspectable open var maxHeight: CGFloat = 0 {
        didSet { forceLayoutSubviews()}
        
    }
    @IBInspectable open var placeholder: String? {
        didSet { setNeedsDisplay() }
        
    }
    @IBInspectable open var placeholderColor: UIColor = UIColor(white: 0.8, alpha: 1.0) {
        didSet { setNeedsDisplay() }
        
    }
    open var attributedPlaceholder: NSAttributedString? {
        didSet { setNeedsDisplay() }
    }
    
    override public init(frame:CGRect,textContainer:NSTextContainer?) {
        super.init(frame: frame,textContainer: textContainer)
        commonInit()
        
    }
    required public init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        contentMode = .redraw
        associateConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(textVDidChange), name:
                                                UITextView.textDidChangeNotification,object: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing), name:
                                                UITextView.textDidEndEditingNotification, object: self)
        
        initInputAccessoryView()
        
    }
    
   private func initInputAccessoryView() {
        manager = self.undoManager!
       self.returnKeyType = .next
        if menuView == nil {
            let menuView = UIToolbar(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 44))
            menuView.barStyle = .default

            lastStepBtn = UIButton(type: .custom)
            lastStepBtn.setImage("back-disable".image, for: .disabled)
            lastStepBtn.setImage("back-enable".image, for: .normal)
            lastStepBtn.addTarget(self, action: #selector(lastStepBtnClick), for: .touchUpInside)
            let lastStepItem = UIBarButtonItem(customView: lastStepBtn)

            
            let space = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            space.width = 30
            
            nextStepBtn = UIButton(type: .custom)
            nextStepBtn.setImage("next-disable".image, for: .disabled)
            nextStepBtn.setImage("next-enable".image, for: .normal)
            nextStepBtn.addTarget(self, action: #selector(nextStepBtnClick), for: .touchUpInside)
            let nextStepItem = UIBarButtonItem(customView: nextStepBtn)

            menuView.setItems([lastStepItem, space, nextStepItem], animated: true)

            self.inputAccessoryView = menuView
            self.menuView = menuView
        }
        
        lastStepBtn.isEnabled = manager.canUndo
        nextStepBtn.isEnabled = manager.canRedo
    }
    
    @objc func lastStepBtnClick() {

        manager.undo()
        lastStepBtn.isEnabled = manager.canUndo
        nextStepBtn.isEnabled = manager.canRedo
    }
    
    @objc func nextStepBtnClick() {

        manager.redo()
        lastStepBtn.isEnabled = manager.canUndo
        nextStepBtn.isEnabled = manager.canRedo
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric,height: 30)
    }
    
    private func associateConstraints() {
        for constraint in constraints {
            if constraint.firstAttribute == .height && constraint.relation == .equal {
                heightConstraint = constraint
            }
        }
    }
    
    // Calculate and adjust textview's height private
    var oldText: String = ""
    private var oldSize: CGSize = .zero
    
    private func forceLayoutSubviews() {
        oldSize = .zero
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private var shouldScrollAfterHeightChanged = false
    
    override open func layoutSubviews() {
        super.layoutSubviews( )
        if text == oldText && bounds.size == oldSize { return }
        oldText = text
        oldSize = bounds.size
        let size = sizeThatFits(CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        
        
        var height = size.height
        // Constrain minimum height
        height = minHeight > 0 ? max(height,minHeight) : height
        // Constrain maximum height
        height = maxHeight > 0 ? min(height,maxHeight) : height
        // Add height constraint if it is not found
        if heightConstraint == nil {
            heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height)
            addConstraint(heightConstraint!)
        }
        // Update height constraint if needed
        if height != heightConstraint!.constant {
            shouldScrollAfterHeightChanged = true
            heightConstraint!.constant = height
            if let delegate = delegate as? GrowingTextViewDelegate {
                delegate.textViewDidChangeHeight(self, height: height)
            } else if shouldScrollAfterHeightChanged {
                shouldScrollAfterHeightChanged = false
                scrollToCorrectPosition()
                
            }
        }
    }
    
    private func scrollToCorrectPosition() {
        if self.isFirstResponder {
            self.scrollRangeToVisible(NSRange(location: -1,length: 0)) // Scroll to bottom
        }else {
            self.scrollRangeToVisible(NSRange(location: 0, length: 0)) // scroll to top
        }
    }
    
    // Show placeholder if needed
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        if text.isEmpty {
            let xValue = textContainerInset.left + textContainer.lineFragmentPadding
            let yvalue = textContainerInset.top
            let width = rect.size.width - xValue - textContainerInset.right
            let height = rect.size.height - yvalue - textContainerInset.bottom
            let placeholderRect = CGRect(x: xValue, y: yvalue, width: width, height: height)
            if let attributedPlaceholder = attributedPlaceholder {
                // Prefer to use attributedPlaceholder
                attributedPlaceholder.draw(in:placeholderRect)
                
            } else if let placeholder = placeholder {
                // otherwise user placeholder and inherit 'text’ attributes
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = textAlignment
                var attributes: [NSAttributedString.Key: Any]=[
                    .foregroundColor: placeholderColor,
                    .paragraphStyle: paragraphStyle]
                
                if let font = font{
                    attributes[.font] = font
                    
                }
                placeholder.draw(in: placeholderRect, withAttributes: attributes)
            }
        }
    }
    
    // Trim white space and new line characters when end editing.
    @objc private func textDidEndEditing(notification: Notification) {
        if let sender = notification.object as? GrowingTextView, sender == self {
            if trimWhiteSpaceWhenEndEditing {
                text = text?.trimmingCharacters(in:.whitespacesAndNewlines)
                setNeedsDisplay()
                scrollToCorrectPosition()
            }
            manager.removeAllActions()
            lastStepBtn.isEnabled = false
            nextStepBtn.isEnabled = false
        }
    }
    
    @objc private func textVDidChange(notification: Notification) {
        if let sender = notification.object as? GrowingTextView, sender == self {
            if maxLength > 0 && text.count > maxLength {
                let endIndex = text.index(text.startIndex, offsetBy: maxLength)
                text = String(text[..<endIndex])
                undoManager?.removeAllActions()
                setNeedsDisplay()

            }
            lastStepBtn.isEnabled = manager.canUndo
            nextStepBtn.isEnabled = manager.canRedo
        }
    }
}

