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
    
    #if DEBUG
    lazy var logViewHelper = LogViewHelper(logFilePath: FileManager.logFileURL?.path)
    #endif

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
    
    lazy var connectWidget: HVConnectWidget = {
        let widget = HVConnectWidget.init(frame: .zero)
        widget.connectButton.sb.addEventHandlerForControlEvents(.touchUpInside) { [unowned self] sender in
            self.actionConnectWidget()
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
        
//#if DEBUG
//let leftButton = UIBarButtonItem(title: "WGlog", style: .plain) {
//    self.logViewHelper?.fetchLogEntriesSinceLastFetch(completion: { logEntries in
//        debugPrint("logerVH.count = \(logEntries.count)")
//        for item in logEntries {
//            debugPrint("item = \(item.message)")
//        }
//    })
//}
//self.navigationItem.leftBarButtonItem = leftButton
//#endif

    }
    
    @objc
    func didBecomeActiveNotification() {
        if let beginTime = startTime {
            let duration = Date().secondsSince(beginTime)
            if duration >= 8 {
                ConfigureModel.isShownRateUs = true
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

        
        if !ConfigureModel.isVIP() {
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
        if ConfigureModel.isVIP() {
            self.premiumBanner.isHidden = true
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.premiumBanner.isHidden = false
        }
        
        updateLocation()

        if  justSelectedLocationLock == nil  {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.isActive() {
                    self.setConnectStatus(.connected)
                    self.resetCountdown()
                } else {
    //                if VPNHelper.shared.manager == nil {
    //                    VPNHelper.shared.fetchManager { error in
    //                        if VPNHelper.shared.isConnected() {
    //                            self.setConnectStatus(.connected)
    //                        }
    //                    }
    //                }
                }
            }
        }
    }
    
    func updateLocation() {
//        HVSingleManager.shared.defaultCurrentLocationCheck()
        
        if let location = ConfigureModel.current?.currentLocation {
            locationBanner.update(location)
        }
    }
    
    func rightBarItemAction() {
        actionPremiumBanner()
    }
    
    func actionPremiumBanner() {
        showPremium()
    }
    
    func showPremium() {
        let vc = GGVipViewController1()
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
        let vc = HVFreeLocationTableViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc)
    }
    
    func resetCountdown() {
        debugPrint("resetCountdown occurred")
        
        // reset start time to make realRemainderTime corect
        if !VPNHelper.shared.isConnected() {
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
        guard let _ = ConfigureModel.current?.currentLocation else {
            return self.showLocaiton()
        }
        
        if self.connectWidget.state == .connect {
            guard ConfigureModel.isVIP() else { return showPremium() }
            
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
    
    lazy var viewModel: VPNViewModel = {
        return VPNViewModel(self)
    }()
    var manuleSelectedLocation: LocationModel?
}

extension MVHomeViewController: HVLocationSelectedProtocol {
    func actionDidSelectLocation(_ model: LocationModel) {
        
        justSelectedLocationLock = model.id?.string ?? "xx" // will reset at connect successed
        let shouldStopBefore = VPNHelper.shared.isConnected()

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
        
//        VPNHelper.shared.hasAuthorization { result in
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
//                VPNHelper.shared.loadVPNPreference { error in
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
        viewModel.start(nodes: nodes) { error in
        }

//        if let array = nodes {
//            viewModel.updateConfig(nodes: array)
//        }
//
//        if VPNHelper.shared.isConnected() {
//        } else {
//            viewModel.start { error in
//            }
//        }
    }
    
    func stop() {
        viewModel.stop()
    }
    
    func isActive() -> Bool {
        return VPNHelper.shared.isConnected()
    }
    
    func refreshIPAfter(second: Double=1) {
        if let node = ConfigureModel.current?.currentNode, let ip = node.ip {
            DispatchQueue.main.asyncAfter(deadline: .now() + second) {
                VPNStatusCheck.ipConnectCheck(node) { result in
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
        guard let selector = ConfigureModel.current?.currentLocation else { return }
        guard let serverIP = selector.serverIP else { return }
//        #if DEBUG
//        let aSer = "207.148.95.104"
//        #endif
        MVDataManager.fetchFirstConfigAndDropIt(serverIP) { dict, err in
            //延迟返回数据检查
            guard let currentSelectorIP = ConfigureModel.current?.currentLocation?.serverIP else { return }
            guard currentSelectorIP == serverIP else { return }

            if let dict = dict, let model = NodeModel.deserialize(from: dict) {
                self.connect(nodes: [model])
            } else {
                self.setConnectStatus(.connect)
            }
        }
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

