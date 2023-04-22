//
//  MVHomeViewController.swift
//  FastVPN
//
//  Created by Justin on 2022/9/21.
//

import Foundation
import DeviceKit
import HandyJSON

class MVHomeViewController: LXBaseViewController {
    
    var waitAdsFirstTime = false
    var justSelectedLocationLock: String? = nil  // will reset at connnect success
    var startTime: Date?
    var starView: UIView?
    var ratingView: RatingView?
    
    lazy var premiumBanner: UIControl = {
        let vc = HVConnectWidget.createPremiumControl()
        vc.sb.addEventHandlerForControlEvents(.touchUpInside) { [unowned self] _ in
            self.actionPremiumBanner()
        }
        return vc
    }()
    
    lazy var locationBanner: HVLocationBanner = {
        let view = HVLocationBanner.init(frame: CGRect(x: 20, y: SCREEN_HEIGHT_WITHOUT_TOP_BOTTOM_BAR - 55 - 68 - 20, width: SCREEN_WIDTH - 2*20, height: 68))
        view.sb.addEventHandlerForControlEvents(.touchUpInside) { [unowned self] _ in
            self.actionLocaiton()
        }
        return view
    }()
    
    var actionProtect = false
    lazy var connectWidget: HVConnectWidget = {
        let widget = HVConnectWidget.init(frame: .zero)
        widget.connectButton.sb.addEventHandlerForControlEvents(.touchUpInside) { [unowned self] sender in
            guard self.actionProtect == false else { return }
            
            self.actionConnectWidget()
            self.actionProtect = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.actionProtect = false
            }
        }
        return widget
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationItem.titleView = UIImageView(image: UIImage(named: "title_icon"))
        self.navigationItem.title = "Warp VPN"
        
        self.view.addSubview(locationBanner)
        self.view.addSubview(connectWidget)
        connectWidget.centerY = locationBanner.top/2 + 10
        connectWidget.centerX = self.view.width/2
        connectWidget.state = .connecting
        
        self.view.addSubview(premiumBanner)
        premiumBanner.centerX = self.view.width/2
        premiumBanner.bottom = SCREEN_HEIGHT_THUMB - (20 + self.additionalSafeAreaInsets.bottom)

        let banner = createBannerView()
        self.view.addSubview(banner)
        starView = banner

        setConnectStatus(.connect, animation: false)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)        
    }
    
    @objc
    func didBecomeActiveNotification() {
        if let beginTime = startTime {
            let duration = Date().secondsSince(beginTime)
            if duration >= 8 {
                MVConfigModel.isShownRateUs = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        updateVIPStateUI()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .clear
        appearance.backgroundImage = UIImage.init(color: .backgroundColor, size: CGSize(width: SCREEN_WIDTH, height: 100))
        appearance.shadowImage = UIImage()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(hexString: "#FFFFFF")!, .font: UIFont.boldMontserratFont(ofSize: 16)]

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.backgroundColor = appearance.backgroundColor
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()
        tabAppearance.backgroundColor = .lightBackground
//        tabAppearance.shadowColor = .backgroundColor
        tabBarController?.tabBar.unselectedItemTintColor = .white.alpha(0.6)
        tabBarController?.tabBar.standardAppearance = tabAppearance
        tabBarController?.tabBar.scrollEdgeAppearance = tabAppearance

        if !MVConfigModel.isVIP() {
            let button = UIButton(type: .custom)
            button.setTitle("Upgrade", for: .normal)
            button.setImage(UIImage(named: "vip_icon"), for: .normal)
            button.titleLabel?.font = .boldMontserratFont(ofSize: 10)
            button.layoutButtonImage(space: 6)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
            button.onTap {
                self.showPremium()
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func updateVIPStateUI() {
        if MVConfigModel.isVIP() {
            self.premiumBanner.isHidden = true
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.premiumBanner.isHidden = false
        }
        
        updateLocationIfNeeded()

        if  justSelectedLocationLock == nil  {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.isActive() {
                    self.setConnectStatus(.connected)
                    self.resetCountdown()
                } else {
    //                if MVVPNTool.shared.manager == nil {
    //                    MVVPNTool.shared.fetchManager { error in
    //                        if MVVPNTool.shared.isConnected() {
    //                            self.setConnectStatus(.connected)
    //                        }
    //                    }
    //                }
                }
            }
        }
    }
    
    func updateLocationIfNeeded() {
        if let location = MVConfigModel.current?.currentNode {
            locationBanner.update(location)
        } else {
            MVDataManager.fetchLocationList { _, _ in
                if let location = MVConfigModel.current?.currentNode {
                    self.locationBanner.update(location)
                }
            }
        }
    }
    
    func rightBarItemAction() {
        actionPremiumBanner()
    }
    
    func actionPremiumBanner() {
        showPremium()
    }
    
    func showPremium() {
        let vc = MVPremiumViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true)

        vc.complete = { [unowned vc] (result, errMsg) in
            vc.dismiss(animated: true) {
//                completion()
            }
        }
    }
    
    func actionLocaiton() {
        showLocaiton()
    }
    
    func showLocaiton() {
        let vc = MVFreeLocationTableViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc)
    }
    
    func resetCountdown() {
        debugPrint("resetCountdown occurred")
        
        // reset start time to make realRemainderTime corect
        if !MVVPNTool.shared.isConnected() {
            GGTunnelStore(appGroup: AppGroup).startTime = nil
            connectWidget.countLabel.stop()
        } else {
            if let startTime = GGTunnelStore(appGroup: AppGroup).startTime {
                debugPrint("resetCountdown startTime = \(startTime)")

                connectWidget.countLabel.startCount(from: startTime)
            } else {
                let isWG = GGTunnelStore(appGroup: AppGroup).isWireGuard
                debugPrint("resetCountdown startTime nill, isWireGuard = \(isWG)")
            }
        }
    }

    func actionConnectWidget() {
        guard let _ = MVConfigModel.current?.currentNode else {
            return self.showLocaiton()
        }
        
        if self.connectWidget.state == .connect {
            guard MVConfigModel.isVIP() else { return showPremium() }
            
            self.setConnectStatus(.connect, animation: false)
            self.setConnectStatus(.connecting)
            self.connect(nodes: nil)
        } else if self.connectWidget.state == .connected {
            
            self.stop()
            self.setConnectStatus(.connect)
            
            self.showStarViewIfNeeded()
        } else if self.connectWidget.state == .connecting {
            self.stop()
            self.setConnectStatus(.connect)
        }
    }
    
    lazy var viewModel: MVProxyViewModel = {
        return MVProxyViewModel(self)
    }()
    var manuleSelectedLocation: NodeModel?
}

extension MVHomeViewController: HVLocationSelectedProtocol {
    func actionDidSelectLocation(_ model: NodeModel) {
        
        justSelectedLocationLock = model.id?.string ?? "xx" // will reset at connect successed
        let shouldStopBefore = MVVPNTool.shared.isConnected()

        if shouldStopBefore {
            self.viewModel.shouldRestart = true
            self.viewModel.shouldRestartGetNewNodes = true
            self.stop()
        }

        self.setConnectStatus(.connect, animation: false)
        self.setConnectStatus(.connecting)
        
        
        
        
        // 必须在已经断开连接的情况下发起请求，否则可能在网络请求过程中失败
        // shouldStopBefore 在收到disconnect消息后发起连接
        if !shouldStopBefore {
            fetchNodeAndConnenct()
        }
    }

    func connect(nodes: [NodeModel]?, adsFlag: Bool=false, forceRefresh: Bool=false) {
        
//        MVVPNTool.shared.hasAuthorization { result in
//            if result {
                // forceRefresh
                guard !forceRefresh else { return self.fetchNodeAndConnenct() }
                // Empty nodes
                guard (nodes?.count ?? 0) > 0 else { return self.fetchNodeAndConnenct() }

                // no vip watch ads
//                if !User.isVip() && !adsFlag {
//                    AppRewardAdManager.showInterstitialForce(in: self) { [weak self] _, _ , _ in
//                        self?.connect(nodes: nodes, adsFlag: true)
//                    }
//                    self.interstitialAd.showInterstitial(force: true) { [weak self] _, _ , _ in
//                        self?.connect(nodes: nodes, adsFlag: true)
//                    }
//                    return
//                }
                
                self.start(nodes: nodes)
//            } else {
//                // 获取授权后连接
//                MVVPNTool.shared.loadVPNPreference { error in
//                    if error == nil {
//                        self.connect(nodes: nodes)
//                    } else {
//                    }
//                }
//            }
//        }
    }

    func start(nodes: [NodeModel]?) {
        guard let nodes = nodes else { return }
//        viewModel.start(nodes: nodes) { error in
//        }
        
        viewModel.updateConfig(nodes: nodes)

        viewModel.start { error in
            
        }

//        if let array = nodes {
//            viewModel.updateConfig(nodes: array)
//        }
//
//        if MVVPNTool.shared.isConnected() {
//        } else {
//            viewModel.start { error in
//            }
//        }
    }
    
    func stop() {
        viewModel.stop()
    }
    
    func isActive() -> Bool {
        return MVVPNTool.shared.isConnected()
    }
    
    func refreshIPAfter(second: Double=1) {
        if let node = MVConfigModel.current?.currentNode, let ip = node.ip {
            DispatchQueue.main.asyncAfter(deadline: .now() + second) {
                MVConnectionCheck.ipConnectCheck(node) { result in
                    guard result == true else { return }
                    DispatchQueue.main.async {
                        self.resetCountdown()
//                        self.connectWidget.setConnectedIP(ip)
                    }
                }
            }
        }
    }
    
    func fetchNodeAndConnenct() {
        if let model = MVConfigModel.current?.currentNode {
            self.connect(nodes: [model])
        }
        
//        guard let selector = MVConfigModel.current?.currentNode else { return }
//        guard let serverIP = selector.serverIP else { return }
////        #if DEBUG
////        let aSer = "207.148.95.104"
////        #endif
//        MVDataManager.fetchNode(serverIP) { model, err in
//            //延迟返回数据检查
//            guard let currentSelectorIP = MVConfigModel.current?.currentNode?.serverIP else { return }
//            guard currentSelectorIP == serverIP else { return }
//
//            if let model = model {
//                AnalyticsManager.logEvent(serverIP, event1: "status", value: 1)
//                self.connect(nodes: [model])
//            } else {
//                AnalyticsManager.logEvent(serverIP, event1: "status", value: 0)
//                self.setConnectStatus(.connect)
//            }
//        }
    }
    
    func setConnectStatus(_ status:ConnectStatus, animation: Bool=true) {
        connectWidget.state = status
        debugPrint("setConnectStatus  =====  = = == = = ", status)
    }
}

extension MVHomeViewController: LXVPNProtocol {
    func connected() {
        debugPrint("GGFirstTabViewController connected")
        justSelectedLocationLock = nil
        setConnectStatus(.connected)
//        refreshIPAfter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.resetCountdown()
        }
    }
    
    func disconnected() {
        debugPrint("GGFirstTabViewController disconnected")

        // 从location列表选中返回，先执行断开连接，确认连接已断开再重启连接
        justSelectedLocationLock = nil
        if viewModel.shouldRestartGetNewNodes == true {
            // 延迟1秒执行，等待网络恢复
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.fetchNodeAndConnenct()
            }
            viewModel.shouldRestartGetNewNodes = false
            viewModel.shouldRestart = false
        } else {
            setConnectStatus(.connect)
        }
        resetCountdown()
    }
}

