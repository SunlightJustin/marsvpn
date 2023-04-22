//
//  EditProfileViewController.swift
//  Kinker
//
//  Created by clove on 8/3/20.
//  Copyright © 2020 personal.Justin. All rights reserved.
//

import Foundation

protocol HVLocationSelectedProtocol {
    func actionDidSelectLocation(_ model: NodeModel)
}

class MVFreeLocationTableViewController: LXBaseTableViewController {
    
    var locations = [NodeModel]()
                
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Server List"
        
        self.tableView.backgroundColor = .backgroundColor
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        self.tableView.rowHeight = 68
//        self.tableView.estimatedRowHeight = 68
        self.tableView.register(MVLocationCell.self, forCellReuseIdentifier: "MVLocationCell")
        self.tableView.separatorStyle = .none
        self.tableView.separatorColor = .clear
        self.tableView.contentInset = .zero
        
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .clear
        appearance.backgroundImage = UIImage.init(color: .backgroundColor, size: CGSize(width: SCREEN_WIDTH, height: 100))
        appearance.shadowImage = UIImage()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(hexString: "#FFFFFF")!, .font: UIFont.mediumMontserratFont(ofSize: 20)]

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.backgroundColor = appearance.backgroundColor
        
        if self.locations.count == 0 {
            HUD.startLoading()
            MVDataManager.fetchLocationList { array, error in
                HUD.hide()
                self.reloadData()
                
                if let array = array, array.count == 0 {
                    HUD.flash("No Services")
                }
            }
        } else {
            MVDataManager.fetchLocationList { array, error in
                self.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func reloadData() {
        locations = [NodeModel].init(MVDataManager.shared.locationList)
        tableView.reloadData()
    }
    
    func showPremiumIfNeeded() -> Bool {
        
        let vc = MVPremiumViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true)

        vc.complete = { [unowned vc] (result, errMsg) in
            vc.dismiss(animated: true) {
            }
        }
        
        return false
    }
    
    var delegate: HVLocationSelectedProtocol?
    func actionSelectNode(_ model: NodeModel) {
        
        MVConfigModel.current?.currentNode = model
        MVConfigModel.current?.saveToFile1()

        self.tableView.reloadData()
        
        self.delegate?.actionDidSelectLocation(model)
        self.navigationController?.popViewController(animated: true)
    }
}

extension MVFreeLocationTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MVLocationCell", for: indexPath) as! MVLocationCell
        guard locations.count > indexPath.row else { return cell }
        let model = locations[indexPath.row]
        
        cell.update(model)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
        
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MVLocationCell {
            cell.isSelected = false
        }

        guard locations.count > indexPath.row else { return }
        let model = locations[indexPath.row]
        
        if !model.isFree && !MVConfigModel.isVIP() {
            showPremiumIfNeeded()
            return
        }
        
        self.actionSelectNode(model)
    }
}

