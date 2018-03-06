//
//  ADVSegmentedControl.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/18/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

@IBDesignable class ADVSegmentedControl: UIControl {

    fileprivate var labels = [UILabel]()
    var thumbView = UIView()
    
    var items: [String] = ["Item 1", "Item 2"] {
        didSet {
            setupLabels()
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    
    @IBInspectable var selectedLabelColor: UIColor = .black {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable var unselectedLabelColor: UIColor = .white {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable var thumbColor: UIColor = .white {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable var borderColor: UIColor = .white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var font: UIFont! = UIFont.systemFont(ofSize: 12) {
        didSet {
            setFont()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)!
        setupView()
    }
    
    func setupView() {
        layer.cornerRadius = frame.height / 2
        layer.borderColor = UIColor(white: 1.0, alpha: 0.5).cgColor
        layer.borderWidth = 2
        backgroundColor = UIColor.clear
        
        setupLabels()
        addIndividualItemConstraints(labels, mainView: self, padding: 0)
        insertSubview(thumbView, at: 0)
    }
    
    func setupLabels() {
        for label in labels {
            label.removeFromSuperview()
        }
        
        for index in 1...items.count {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
            label.text = items[index - 1]
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.font = UIFont(name: "Avenir-Black", size: 15)
            label.textColor = index == 1 ? selectedLabelColor : unselectedLabelColor
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(label)
            labels.append(label)
        }
        addIndividualItemConstraints(labels, mainView: self, padding: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var selectFrame = self.bounds
        selectFrame.size.width = selectFrame.width / CGFloat(items.count)
        thumbView.frame = selectFrame
        thumbView.backgroundColor = thumbColor
        thumbView.layer.cornerRadius = thumbView.frame.height / 2
        
        displayNewSelectedIndex()
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        var calculatedIndex: Int?
        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
        return false
    }
    
    func displayNewSelectedIndex() {
        for label in labels{
            label.textColor = unselectedLabelColor
        }
        
        let label = labels[selectedIndex]
        label.textColor = selectedLabelColor
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8,
                       options: [], animations: {
                        self.thumbView.frame = label.frame
        }, completion: nil)
    }
    
    func addIndividualItemConstraints(_ items: [UIView], mainView: UIView, padding: CGFloat) {
        for (index, button) in items.enumerated() {
            let topConstraint = NSLayoutConstraint(item: button,
                                                   attribute: .top,
                                                   relatedBy: .equal,
                                                   toItem: mainView,
                                                   attribute: .top,
                                                   multiplier: 1.0,
                                                   constant: 0)
            
            let bottomConstraint = NSLayoutConstraint(item: button,
                                                   attribute: .bottom,
                                                   relatedBy: .equal,
                                                   toItem: mainView,
                                                   attribute: .bottom,
                                                   multiplier: 1.0,
                                                   constant: 0)
            
            var rightConstraint: NSLayoutConstraint!
            if index == items.count - 1 {
                rightConstraint = NSLayoutConstraint(item: button,
                                                      attribute: .right,
                                                      relatedBy: .equal,
                                                      toItem: mainView,
                                                      attribute: .right,
                                                      multiplier: 1.0,
                                                      constant: -padding)
            } else {
                rightConstraint = NSLayoutConstraint(item: button,
                                                     attribute: .right,
                                                     relatedBy: .equal,
                                                     toItem: mainView,
                                                     attribute: .left,
                                                     multiplier: 1.0,
                                                     constant: -padding)
            }
            
            var leftConstraint: NSLayoutConstraint!
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button,
                                                     attribute: .left,
                                                     relatedBy: .equal,
                                                     toItem: mainView,
                                                     attribute: .left,
                                                     multiplier: 1.0,
                                                     constant: padding)
            } else {
                let prevButton = items[index - 1]
                leftConstraint = NSLayoutConstraint(item: button,
                                                    attribute: .left,
                                                    relatedBy: .equal,
                                                    toItem: prevButton,
                                                    attribute: .right,
                                                    multiplier: 1.0,
                                                    constant: padding)
                let firstItem = items[0]
                let widthConstraint = NSLayoutConstraint(item: button,
                                                         attribute: .width,
                                                         relatedBy: .equal,
                                                         toItem: firstItem,
                                                         attribute: .width,
                                                         multiplier: 1.0,
                                                         constant: 0)
                mainView.addConstraint(widthConstraint)
            }
            mainView.addConstraints([topConstraint, rightConstraint, leftConstraint])
        }
    }
    
    func setSelectedColors() {
        for item in labels {
            item.textColor = unselectedLabelColor
        }
        if labels.count > 0 {
            labels[0].textColor = selectedLabelColor
        }
        thumbView.backgroundColor = thumbColor
    }
    
    func setFont() {
        for item in labels {
            item.font = font
        }
    }
    
    
}
