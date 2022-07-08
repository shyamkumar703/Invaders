// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

final class SupportViewController: BaseViewController {

    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        return tableView
    }()
    
    private lazy var logOutButton: ContinueButton = {
        let button = ContinueButton()
        button.setTitle("Log Out", for: .normal)
        button.setColor(color: .lostRed)
        button.onPress { [weak self] in
            self?.logOut()
        }
        return button
    }()
    
    private lazy var deleteAccountButton: UIButton = {
        let button = UIButton()
        
        let attributedText = NSAttributedString(
            string: "Delete Account",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.grayish,
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
        
        button.setAttributedTitle(attributedText, for: .normal)
        let deleteAccountButtonTapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(deleteAccountButtonTap)
        )
        button.addGestureRecognizer(deleteAccountButtonTapGestureRecognizer)
        return button
    }()
    
    private var viewModel: SupportViewModel
    
    init(viewModel: SupportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.viewDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCommon()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLeftTopNavButton(type: .back)
        Task { [weak self] in
            await self?.viewModel.markFaqMissionAsComplete()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

// MARK: - Setup

private extension SupportViewController {
    func setupCommon() {
        view.backgroundColor = .black
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInsetReference = .fromCellEdges
        tableView.separatorInset = .zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = 0

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        register()
        
        // footer with logout button
        tableView.tableFooterView = createTableViewFooter()

        view.addSubview(tableView)
        setupTableViewConstrains()
    }
    
    func createTableViewFooter() -> UITableViewHeaderFooterView {
        let footer = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: 100, height: 140))
        let view = UIView()
        footer.backgroundView = view
        footer.backgroundView?.backgroundColor = .clear
        
        footer.addSubview(logOutButton)
        footer.addSubview(deleteAccountButton)
        
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logOutButton.heightAnchor.constraint(equalToConstant: 50),
            logOutButton.widthAnchor.constraint(equalToConstant: 300),
            logOutButton.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
            logOutButton.topAnchor.constraint(equalTo: footer.topAnchor, constant: 30),
            logOutButton.bottomAnchor.constraint(equalTo: deleteAccountButton.topAnchor, constant: -10)
        ])
        
        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 50),
            deleteAccountButton.widthAnchor.constraint(equalToConstant: 300),
            deleteAccountButton.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
            deleteAccountButton.topAnchor.constraint(equalTo: logOutButton.bottomAnchor, constant: 10)
        ])
        
        return footer
    }
    
    @objc func deleteAccountButtonTap() {
        viewModel.deleteAccount()
    }
}

// MARK: - Setup Table View

private extension SupportViewController {
    func register() {
        registerCell(SupportHeaderCell.self)
        registerCell(SupportPrimaryCell.self)
        registerCell(SupportExpandableCell.self)
//        registerCell(SupportProfileCell.self)
    }

    func registerCell<T: UITableViewCell>(_: T.Type) {
        tableView.register(T.self, forCellReuseIdentifier: T.identifier)
    }
}

extension SupportViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch viewModel.getSection(at: section) {
        case .faq(var viewModel):
            viewModel.viewDelegate = self
            return SuppoortSectionHeaderView(viewModel: viewModel.headerViewModel)
        default:
            return UIView(frame: .zero)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch viewModel.getSection(at: section) {
        case .faq:
            return 52
        default:
            return 10
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch viewModel.getSection(at: section) {
        case .header:
            return 20
        case .profile:
            return 10
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.getSection(at: indexPath.section) {
        case .header: return 82
        case .primary, .profile: return 78
        case .faq: return tableView.rowHeight
        default: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumberOfItems(at: section)
    }
    
    private func dequeueReusableCell<T: UITableViewCell>(
        _: T.Type,
        _ viewModel: SupportCellViewModel?,
        for indexPath: IndexPath
    ) -> UITableViewCell {
        let view = tableView.dequeueReusableCell(withIdentifier: T.identifier, for: indexPath)
        
        switch view {
        case let cell as SupportHeaderCell:
            cell.viewModel = viewModel
            return cell
        case let cell as SupportPrimaryCell:
            cell.viewModel = viewModel
            return cell
        case let cell as SupportPrimaryCell:
            cell.viewModel = viewModel
            return cell
        case let cell as SupportExpandableCell:
            cell.configure(viewModel: viewModel)
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.getSection(at: indexPath.section) {
        case .header(let viewModel):
            return dequeueReusableCell(SupportHeaderCell.self, viewModel, for: indexPath)
        case .primary(let items):
            let viewModel = items.indices.contains(indexPath.row) ? items[indexPath.row] : nil
            return dequeueReusableCell(SupportPrimaryCell.self, viewModel, for: indexPath)
        case .profile(let viewModel):
            return dequeueReusableCell(SupportPrimaryCell.self, viewModel, for: indexPath)
        case .faq(let viewModel):
            return dequeueReusableCell(
                SupportExpandableCell.self,
                viewModel.prepareViewModel(for: indexPath.row),
                for: indexPath
            )
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let haptics = UIImpactFeedbackGenerator()
        haptics.impactOccurred()
        viewModel.didSelectRowAt(indexPath.row, section: indexPath.section)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

// MARK: - SupportFaqViewModelViewDelegate

extension SupportViewController: SupportFaqViewModelViewDelegate {
    func supportFaqShowAllDidPress() {
        self.tableView.reloadData()
    }
}

// MARK: - Constrains

private extension SupportViewController {
    func setupTableViewConstrains() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Log out

private extension SupportViewController {
    func logOut() {
        viewModel.logout()
    }
}

extension SupportViewController: SupportViewModelViewDelegate {
    func showLoadingProcess() {
        startActivityIndicator()
    }
    
    func hideLoadingProcess() {
        stopActivityIndicator()
    }
}
