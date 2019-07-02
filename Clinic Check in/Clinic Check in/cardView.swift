//
//  cardView.swift
//  Clinic Check in
//
//  Created by MK on 17/05/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit

@IBDesignable class cardView: UIView {
    
    @IBInspectable var cornerRadius : CGFloat = 2
    @IBInspectable var shadowOffsetWidth : CGFloat = 0
    @IBInspectable var shadowOffsetHeight : CGFloat = 2
    @IBInspectable var shadowColor : UIColor = UIColor.black
    @IBInspectable var shadowOpacity : CGFloat = 0.2
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize.init(width: shadowOffsetWidth, height: shadowOffsetHeight)
        let shadowPath = UIBezierPath.init(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowOpacity = Float(shadowOpacity)
    }
    
}
