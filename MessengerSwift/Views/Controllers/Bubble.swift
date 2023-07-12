//
//  Bubble.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 12.07.2023.
//

import UIKit

class BubbleView: UIView {
    
    var label = UILabel() // label özelliği eklendi
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Arka plan rengi ve şekli ayarları
        backgroundColor = UIColor.lightGray
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        // Metin etiketi oluşturma ve ayarları
        label = UILabel(frame: CGRect(x: 10, y: 10, width: frame.width - 20, height: frame.height - 20))
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0 // Birden fazla satıra sığmasını sağlar
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
