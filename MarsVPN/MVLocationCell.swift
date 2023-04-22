//
//  MVLocationCell.swift
//  FastVPN
//
//  Created by Justin on 2022/9/27.
//

import Foundation
import Kingfisher
    
public class MVLocationCell: UITableViewCell {
    
    lazy var flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius = 16
//        imageView.layer.borderColor = UIColor.white.cgColor
//        imageView.layer.borderWidth = 1
//        imageView.layer.masksToBounds = true
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
//            make.top.equalTo(12)
        }
        return imageView
    }()
    
    lazy var contentLabel: UILabel = {
        var label = UILabel()
        label.font = .regularMontserratFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = .white
        self.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(self.flagImageView.snp.right).offset(16)
            make.height.equalTo(22)
        }
        return label
    }()
    
    lazy var contentLabelMirror: UILabel = {
        var label = UILabel()
        label.font = .regularMontserratFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = .white
        self.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(self.flagImageView.snp.right).offset(16)
            make.height.equalTo(22)
            make.centerY.equalTo(self.flagImageView.snp.centerY)
            make.right.equalTo(self.contentLabel.snp.right)
        }
        label.isHidden = true
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        var label = UILabel()
        label.font = .regularSystemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = .init(hex: "#0D2940").alpha(0.6)
        self.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(self.contentLabel.snp.bottom).offset(1)
            make.left.equalTo(self.contentLabel.snp.left)
            make.right.equalTo(self.contentLabel.snp.right)
            make.height.equalTo(17)
        }
        return label
    }()
    
    lazy var selectedImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "checkbox_selected"))
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.right.equalTo(-16)
            make.centerY.equalTo(self.flagImageView.snp.centerY)
            make.left.equalTo(self.contentLabel.snp.right).offset(16)
        }
        return imageView
    }()
    
    lazy var normalImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "checkbox_normal"))
//        imageView.cornerRadius = 12
//        imageView.borderColor = UIColor.init(hex: "#CCCCCC")
//        imageView.borderWidth = 2
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.right.equalTo(-16)
            make.centerY.equalTo(self.flagImageView.snp.centerY)
        }
        return imageView
    }()
        
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let view = UIImageView(frame: self.bounds)
        view.backgroundColor = .backgroundColor
//        let colorView = UIImageView(frame: view.bounds)
//        colorView.height = 60
//        colorView.top = 0
//        colorView.left = 16
//        colorView.width = SCREEN_WIDTH - 16*2
//        colorView.cornerRadius = 60
//        colorView.backgroundColor = .init(hex: "#1F273D")
//        view.addSubview(colorView)
        self.selectedBackgroundView = view
        
        self.backgroundColor = .backgroundColor
//        self.separatorInset = UIEdgeInsets(horizontal: SCREEN_WIDTH/2, vertical: 0)
        self.contentView.cornerRadius = 30
//        self.contentView.borderWidth = 1
//        self.contentView.borderColor = .init(hex: "#CCCCCC")
        self.contentView.backgroundColor = .init(hex: "#1F273D")
        self.contentView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(0)
//            make.height.equalTo(60)
            make.bottom.equalTo(-8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var reuseIdentifier: String? {
        return "MVLocationCell"
    }
    
    var model: NodeModel?
    func update(_ aModel: NodeModel) {
        self.flagImageView.kf.setImage(with: URL(string: aModel.image), placeholder: aModel.flagImage() ?? UIImage(named: "country_flag"))

        self.selectedImageView.isHidden = true
        self.normalImageView.isHidden = true
        if MVConfigModel.current?.currentNode == aModel {
            self.selectedImageView.isHidden = false
        } else {
            self.normalImageView.isHidden = false
        }
        
        self.contentLabel.text = aModel.displayName()
        self.descriptionLabel.text = aModel.remark
        self.contentLabelMirror.text = aModel.displayName()
        self.contentLabel.isHidden = true
        self.descriptionLabel.isHidden = true
        self.contentLabelMirror.isHidden = true
        if aModel.remark.isNilOrEmpty {
            self.contentLabelMirror.isHidden = false
        } else {
            self.contentLabel.isHidden = false
            self.descriptionLabel.isHidden = false
        }
    }

    //    override public var isSelected: Bool {
//        return true
//    }
    
}

