//
//  MVConnectWidget.swift
//  GOGOVPN
//
//  Created by Justin on 2022/8/3.
//

import Foundation
import UIKit
import Kingfisher

enum ConnectStatus: String {
    case connect
    case connecting
    case connected
}

class MVConnectWidget: UIView {
    
    deinit {
        debugPrint("\(#function) \(NSStringFromClass(type(of: self)))")
    }
    
    lazy var connectedTipsLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.text = ""
        label.textAlignment = .center
        label.textColor = .white
        label.width = 300
        label.height = 24
        self.addSubview(label)
        return label
    }()
    
    lazy var connectLabel: UILabel = {
        let label = UILabel()
        label.font = .regularMontserratFont(ofSize: 14)
        label.text = ""
        label.textAlignment = .center
        label.textColor = .white
        label.width = 150
        label.height = 18
        self.addSubview(label)
        return label
    }()
    
    var state = ConnectStatus.connect {
        didSet {
            self.stateDidChanged()
        }
    }
    
    lazy var countLabel: MVIncreaseCountLabel = {
        let imageView = MVIncreaseCountLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 24))
        return imageView
    }()
    
    lazy var connectButtonContainer: UIView = {
        let imageView = UIView(frame: CGRect(x: 0, y: 0, width: 140, height: 140))
        imageView.cornerRadius = imageView.width/2
        imageView.backgroundColor = .backgroundColor
        return imageView
    }()
    
    lazy var connectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "connect_normal")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(UIImage(named: "connect_selected")?.withRenderingMode(.alwaysOriginal), for: .selected)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 208, height: 208))
        self.clipsToBounds = false
        
        self.addSubview(waveAnimationView)
        waveAnimationView.center = self.bounds.center

        connectButtonContainer.frame = CGRect(x: 0, y: 0, width: 140, height: 140)
        connectButtonContainer.center = self.bounds.center
        self.addSubview(connectButtonContainer)

        connectButton.frame = self.bounds
        connectButton.center = connectButtonContainer.bounds.center
        connectButtonContainer.addSubview(connectButton)
        
        self.addSubview(connectedTipsLabel)
        connectedTipsLabel.bottom = -28
        connectedTipsLabel.centerX = connectButtonContainer.centerX
        
        self.addSubview(connectLabel)
        connectLabel.top = 121
        connectLabel.centerX = connectButtonContainer.centerX
        
        self.addSubview(countLabel)
        countLabel.top = connectButtonContainer.bottom + 34 + 29
        countLabel.centerX = connectButtonContainer.centerX
        countLabel.stop()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func stateDidChanged() {
        switch state {
        case .connect:
            connectButton.isSelected = false
            stopAnimation()
            connectedTipsLabel.text = "Unconnected"
            connectLabel.text = "Connect"
//            connectedTipsLabel.textColor = .white
        case .connecting:
            connectButton.isSelected = false
            startAnimation()
            connectedTipsLabel.text = "Unconnected"
            connectLabel.text = "Connecting"
//            connectedTipsLabel.textColor = .white
        case .connected:
            connectButton.isSelected = true
            stopAnimation()
            connectedTipsLabel.text = "You Are Connected"
            connectLabel.text = "Connected"
//            connectedTipsLabel.textColor = .white
        }
    }
    
    lazy var waveAnimationView: MSWaveAnimationView = {
        let waveAnimationView = MSWaveAnimationView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
//        waveAnimationView.center = button.center
        waveAnimationView.beginRadius = 70
        waveAnimationView.circleColor = UIColor.clear
        waveAnimationView.fillColor =  .theme.alpha(0.3)
        waveAnimationView.duration = 1.75;
        
//        avatarImageView.isHidden = true
        waveAnimationView.isHidden = false
        waveAnimationView.isHidden = true

        return waveAnimationView
    }()
    
    public func startAnimation() {
//        startButton.isHidden = true
//        avatarImageView.isHidden = false
//        avatarImageView.isHidden = false
        waveAnimationView.isHidden = false
        waveAnimationView.moreWave()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
//            self.waveAnimationView.moreWave()
//        }
        connectButtonContainer.clipsToBounds = true
    }
    
    public func stopAnimation() {
        connectButtonContainer.clipsToBounds = false

//        startButton.isHidden = false
//        avatarImageView.isHidden = true
//        avatarImageView.isHidden = false
        waveAnimationView.isHidden = true
        waveAnimationView.stopWave()
    }

    public func isAnimating() -> Bool {
        return !waveAnimationView.isHidden
    }

}


extension MVConnectWidget {
    static func createPremiumControl() -> UIControl {
        let view = UIControl(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 12*2, height: 120))
        
        let bg = UIImageView(image: UIImage(named: "map_bg_radius"))
        view.addSubview(bg)
        view.height = bg.height
        bg.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        let imageView = UIImageView(image: UIImage(named: "icon_vip_40"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.left.equalTo(32)
            make.top.equalTo(36)
        }
        
        let str = "Go premium and get\nfast VPN connection"
        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = 12
        paraph.alignment = .left
        let attributes = [NSAttributedString.Key.paragraphStyle: paraph]
        let attributedStr = NSAttributedString(string: str, attributes: attributes)
        let label = UILabel()
        label.attributedText = attributedStr
        label.font = .mediumSystemFont(ofSize: 18)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.textColor = .white
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(16)
            make.centerY.equalTo(imageView.snp.centerY)
            make.height.equalTo(96)
        }

        let arrow = UIImageView(image: UIImage(named: "arrow_right_white"))
        view.addSubview(arrow)
        arrow.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(18)
            make.left.equalTo(label.snp.right).offset(10)
            make.centerY.equalTo(imageView.snp.centerY)
            make.right.equalTo(-32)
        }
        return view
    }
}


class HVLocationBanner: UIControl {
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .regularMontserratFont(ofSize: 16)
        label.text = ""
        label.textAlignment = .left
        label.textColor = .white
        label.height = 25
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.cornerRadius = 16
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.cornerRadius = 14
        self.clipsToBounds = true
        
        let shadowView = UIView(frame: self.bounds)
        self.addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        shadowView.backgroundColor = .lighterBackground.alpha(0.71)
        shadowView.isUserInteractionEnabled = false

//
//        shadowView.layer.cornerRadius = 28
//        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        shadowView.layer.shadowColor = UIColor.init(white: 0, alpha: 0.2).cgColor
//        shadowView.layer.shadowRadius = 4
//        shadowView.layer.shadowOpacity = 1
//        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 28)
//        shadowView.layer.shadowPath = shadowPath.cgPath
//        shadowView.isUserInteractionEnabled = false
//
//        let shadowView1 = UIView(frame: self.bounds)
//        shadowView1.backgroundColor = .white
//        shadowView1.layer.cornerRadius = 28
//        self.addSubview(shadowView1)
//        shadowView.snp.makeConstraints { make in
//            make.edges.equalTo(0)
//        }
//        shadowView1.isUserInteractionEnabled = false

        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(textLabel)
        textLabel.snp.makeConstraints { [unowned self] make in
            make.height.equalTo(32)
            make.left.equalTo(self.imageView.snp.right).offset(18)
            make.centerY.equalToSuperview()
        }
        
        let arrow = UIImageView(image: UIImage(named: "ic_expand_more_24px"))
        self.addSubview(arrow)
        arrow.snp.makeConstraints { [unowned self] make in
            make.size.equalTo(arrow.size)
            make.left.equalTo(self.textLabel.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalTo(-24)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ model: NodeModel) {
        self.imageView.kf.setImage(with: URL(string: model.image), placeholder: model.flagImage() ?? UIImage(named: "country_flag"))
        self.textLabel.text = model.displayName()
    }
}
