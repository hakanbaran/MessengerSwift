//
//  BubbleCell.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 12.07.2023.
//

import UIKit

class BubbleCell: UITableViewCell {
    
    static let identifier = "BubbleCell"
    
    private let messageLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        label.text = "Hakan BAran Hakan BAran Hakan BAran Hakan BAran Hakan BAran Hakan BAran vvHakan BAran Hakan BAran Hakan BAran Hakan BAran "
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.lightGray
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        
        contentView.addSubview(scrollView)
        scrollView.addSubview(messageLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = contentView.bounds
        
        configureConstraints()
    }
    
    func configureConstraints() {
        let messageLabelConstraints = [
            messageLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 5),
            messageLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 5),
            messageLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -5),
            messageLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 5)
        ]
        NSLayoutConstraint.activate(messageLabelConstraints)
        
        

    }

}




/*
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
 */
