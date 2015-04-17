//
//  SettingsTextCell.swift
//  Ketch
//
//  Created by Tony Xiao on 4/16/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit
import XLForm

class SettingsTextCell : XLFormBaseCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var textView: XLFormTextView!

    override func configure() {
        super.configure()
        textView.delegate = self
        textView.placeholderColor = StyleKit.teal.colorWithAlpha(0.3)
        textView.placeholder = ""
        NC.addObserver(textView, selector: "textChanged:", name: UITextViewTextDidChangeNotification, object: nil)
    }
    
    override func update() {
        super.update()
        iconView.image = UIImage(named: rowDescriptor.title)
        textView.placeholder = rowDescriptor.noValueDisplayText
        textView.text = (rowDescriptor as RowDescriptor).formattedValue
    }
    
    override func formDescriptorCellCanBecomeFirstResponder() -> Bool {
        return !rowDescriptor.disabled
    }
    
    override func formDescriptorCellBecomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    override class func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 60
    }
}

// MARK: -

extension SettingsTextCell : UITextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return formViewController().textViewShouldBeginEditing(textView)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        formViewController().beginEditing(rowDescriptor)
        formViewController().textViewDidBeginEditing(textView)
    }
    
    func textViewDidChange(textView: UITextView) {
        rowDescriptor.value = textView.text?.length > 0 ? textView.text : nil
        formViewController().tableView.beginUpdates()
        formViewController().tableView.endUpdates()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        rowDescriptor.value = textView.text?.length > 0 ? textView.text : nil
        formViewController().endEditing(rowDescriptor)
        formViewController().textViewDidEndEditing(textView)
        formViewController().tableView.beginUpdates()
        formViewController().tableView.endUpdates()
    }
}