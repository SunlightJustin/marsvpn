//
//  GGAvailableTimeControl.swift
//  GOGOVPN
//
//  Created by Justin on 2022/11/18.
//

import Foundation


class MVIncreaseCountLabel: UIControl {
    
    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .init(hex: "#0478FF")
        label.font = .boldMontserratFont(ofSize: 22)
//        label.font = UIFont(name:"Courier", size: 28)?.withTraits(traits: .traitBold)
        label.textAlignment = .center
        return label
    }()
    
    var startDate = Date()
    public func startCount(from date: Date) {
        countLabel.isHidden = false
        startDate = date
        resetLabel()
        CGDTimer.default.invalidate()
        CGDTimer.default.setTimeInterval(interval: 1, isRepeat: true) {
            self.resetLabel()
        }
    }
    
    public func stop() {
        CGDTimer.default.invalidate()
        countLabel.isHidden = true
    }
    
    private func resetLabel() {
        let time = startDate.distance(to: Date())
        
        debugPrint("time = ", time)
        let s = Int(time) % 60
        let m = Int(time / 60) % 60
        let h = Int(time / 60 / 60)
        let str = String(format: "%02d:%02d:%02d", h, m, s)
        countLabel.text = str
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        let bg = UIImageView()
//        bg.borderWidth = 1
//        bg.cornerRadius = 8
//        bg.borderColor = .white
//        self.addSubview(bg)
//        bg.snp.makeConstraints { make in
//            make.edges.equalTo(0)
//        }
//
//        let space0 = UIImageView()
//        self.addSubview(space0)
//        space0.snp.makeConstraints { make in
//            make.left.equalTo(0)
//            make.height.top.equalTo(1)
//            make.width.greaterThanOrEqualTo(1)
//        }

//        let label = UILabel()
//        label.text = Localization.V36.available_time
//        label.font = .mediumSystemFont(ofSize: 16)
//        label.textAlignment = .left
//        label.numberOfLines = 1
//        label.textColor = .white
//        self.addSubview(label)
//        label.snp.makeConstraints { make in
//            make.left.equalTo(24)
//            make.height.equalToSuperview()
//            make.top.equalTo(0)
//        }
        
        self.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
//        let space1 = UIImageView()
//        self.addSubview(space1)
//        space1.snp.makeConstraints { make in
//            make.left.equalTo(self.countdownLabel.snp.right)
//            make.height.top.equalTo(1)
//            make.width.equalTo(space0.snp.width)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}


class CGDTimer: NSObject {
    static let `default` = CGDTimer()
    
    private var timer: DispatchSourceTimer?
    
    deinit {
        timer?.cancel()
    }
    
    // 暂停定时器
    func stop() {
        timer?.suspend()
    }
    
    // 重启定时器
    func restart() {
        timer?.resume()
    }
    
    // 清除定时器
    func invalidate() {
        timer?.cancel()
    }
    
    // 主线程设置CGD定时器
    // interval 时间
    // isRepeat 是否循环
    // block 执行返回
    func setTimeInterval(interval: Int, isRepeat: Bool = false, block: @escaping  () -> Void) {
        // 默认在主队列中调度使用
        timer = DispatchSource.makeTimerSource()
        
        var timeType: DispatchTimeInterval = .never
        if isRepeat {
            timeType = .seconds(interval)
        }
        timer?.schedule(deadline: DispatchTime.now(), repeating: timeType, leeway: .nanoseconds(1))
        
        timer?.setEventHandler {
            DispatchQueue.main.async {
                // 执行任务
                block()
            }
        }
        
        timer?.setRegistrationHandler(handler: {
            DispatchQueue.main.async {
                // Timer开始工作了
            }
        })
//        timer?.activate()
        timer?.resume()
    }
    
    // 线程设置CGD定时器
    // ztimer 对应线程
    // interval 时间
    // isRepeat 是否循环
    // block 执行返回
    func setTimeInterval(ztimer: DispatchSourceTimer, interval: Int, isRepeat: Bool = false, block: @escaping  () -> Void) {
        timer = ztimer

        var timeType: DispatchTimeInterval = .never
        if isRepeat {
            timeType = .seconds(interval)
        }
        timer?.schedule(deadline: DispatchTime.now(), repeating: timeType, leeway: .nanoseconds(1))
        
        timer?.setEventHandler {
            DispatchQueue.main.async {
                // 执行任务
                block()
            }
        }
        
        timer?.setRegistrationHandler(handler: {
            DispatchQueue.main.async {
                // Timer开始工作了
            }
        })
//        timer?.activate()
        timer?.resume()
    }
    
    
}
