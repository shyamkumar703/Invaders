//
//  MissionsViewController.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/16/22.
//

import UIKit
import TriumphCommon

fileprivate var headerId = "header"
fileprivate var otherGamesId = "otherGames"
fileprivate var missionCellId = "missionCell"

protocol OtherGamesViewDelegate: AnyObject {
    func respondToTap(model: OtherGamesCollectionViewModel)
}

protocol MissionsViewDelegate: AnyObject {
    func respondToTap(action: MissionAction, model: MissionModel?)
}

class MissionsViewController: SheetViewController {
    
    var viewModel: MissionsViewModel? {
        didSet {
            viewModel?.viewDelegate = self
        }
    }
    
    lazy var handle: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGrayish
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        return view
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(TournamentsLabelHeader.self, forHeaderFooterViewReuseIdentifier: headerId)
        table.register(MissionTableViewCell.self, forCellReuseIdentifier: missionCellId)
        table.register(OtherGamesTableViewCell.self, forCellReuseIdentifier: otherGamesId)
        table.delegate = self
        table.dataSource = self
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.backgroundColor = .clear
        table.contentInsetAdjustmentBehavior = .never
        table.separatorStyle = .none
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    func setupView() {
        view.backgroundColor = .lead
        
        view.addSubview(handle)
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            handle.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            handle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handle.heightAnchor.constraint(equalToConstant: 4),
            handle.widthAnchor.constraint(equalToConstant: 36),
            
            tableView.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 4),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 12),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension MissionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: otherGamesId, for: indexPath) as? OtherGamesTableViewCell {
                cell.viewModels = viewModel?.otherGames ?? []
                cell.viewDelegate = self
                cell.selectionStyle = .none
                return cell
            } else {
                return UITableViewCell()
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: missionCellId, for: indexPath) as? MissionTableViewCell {
                cell.viewDelegate = self
                guard let missions = viewModel?.missions else { return UITableViewCell() }
                let missionView = MissionView()
                let missionViewModel = MissionViewModelImplementation(model: missions[indexPath.item])
                missionView.viewModel = missionViewModel
                cell.missionView = missionView
                cell.selectionStyle = .none
                return cell
            } else {
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return viewModel?.missions.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        48
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 176
        default:
            return 76
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId) as? TournamentsLabelHeader {
            switch section {
            case 0:
                view.viewModel = TournamentsLabelHeaderViewModel(title: "Other Games", tokenReward: 100)
            case 1:
                let missionsCount = viewModel?.missions.count ?? 0
                view.viewModel = TournamentsLabelHeaderViewModel(
                    title: "\(missionsCount) Mission\(missionsCount != 1 ? "s": "") Available"
                )
            default:
                return nil
            }
            view.backgroundView = UIView()
            view.backgroundView?.backgroundColor = .lead
            return view
        }
        return nil
    }
}

extension MissionsViewController: OtherGamesViewDelegate {
    func respondToTap(model: OtherGamesCollectionViewModel) {
        UIImpactFeedbackGenerator().impactOccurred()
        self.dismiss(animated: true) { [weak self] in
            self?.viewModel?.respondToTap(model: model)
        }
    }
}

extension MissionsViewController: MissionsViewDelegate {
    func respondToTap(action: MissionAction, model: MissionModel?) {
        self.dismiss(animated: true) { [weak self] in
            self?.viewModel?.respondToTap(action: action, model: model)
        }
    }
}

extension MissionsViewController: MissionsViewControllerViewDelegate {
    func reloadTableView(sections: IndexSet) {
        Task { @MainActor [weak self] in
            self?.tableView.reloadSections(sections, with: .none)
        }
    }
}
