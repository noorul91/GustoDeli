//
//  DeliveryTimeView.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

protocol DeliveryTimeViewDelegate: class {
    func timeWasSelected(_ selectedTime: String)
    func cancelButtonTapped()
}

class DeliveryTimeView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    //MARK:- IBOutlets
    @IBOutlet weak var deliveryTimePickerView: UIPickerView!
    @IBOutlet weak var pickerBackView: UIView!
    
    //MARK:- Properties
    weak var delegate: DeliveryTimeViewDelegate!
    var selectedDate = ""
    
    var pickerDataSource: [String]! {
        didSet {
            setupUI()
        }
    }
    
    func showInView(_ aView: UIView!) {
        aView.addSubview(self)
        self.showAnimation()
    }
    
    //MARK:- Private
    fileprivate func setupUI() {
        self.frame = CGRect(x: screenWidth/2 - 187.5, y: screenHeight/2 - 333.5, width: 375, height: 667)
        self.backgroundColor = UIColor().hexStringToUIColor(hexString: "#6F6F6F", alpha: 0.9)
        setupPickerView()
    }
    
    fileprivate func setupPickerView() {
        pickerBackView.layer.cornerRadius = 20.0
        pickerBackView.layer.borderWidth = 2.0
        pickerBackView.layer.borderColor = UIColor.white.cgColor
        if selectedDate != nil {
            if let index = pickerDataSource.index(of: selectedDate) {
                deliveryTimePickerView.selectRow(index, inComponent: 0, animated: true)
            }
        } else {
            selectedDate = pickerDataSource[0]
        }
    }
    
    //MARK:- Action
    @IBAction func tappedCancelButton(_ sender: UIButton) {
        if delegate != nil {
            delegate.cancelButtonTapped()
        }
    }
    
    @IBAction func tappedSetDateButton(_ sender: UIButton) {
        if delegate != nil {
            delegate.timeWasSelected(selectedDate)
        }
    }
    
    //MARK:- UIPickerView implementation
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDate = pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: pickerDataSource[row], attributes: [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Regular", size: 16)!, NSForegroundColorAttributeName: UIColor.white])
    }

}
