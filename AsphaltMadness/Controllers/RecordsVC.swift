import UIKit

class RecordsVC: UIViewController {
    
    private lazy var recordsTableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RecordTableViewCell.self, forCellReuseIdentifier: RecordTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        title = Constants.RecordsScreen.recordsTitle
        
        view.addSubview(recordsTableView)
        recordsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadRecordsHistory() -> [Records] {
        guard let records = UserDefaults.standard.object([Records].self,
                                                         forKey: Constants.UserDefaultsKeys.recordsKey) else {
            return [Records]()
        }
        return records
    }
}

extension RecordsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        loadRecordsHistory().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecordTableViewCell.identifier,
                                                       for: indexPath) as? RecordTableViewCell else {
            return RecordTableViewCell()
        }
        
        let recordsHistory = Array(loadRecordsHistory().reversed())
        let currentRecord = recordsHistory[indexPath.row]
        cell.configureCell(userName: currentRecord.userName,
                           avatarImageName: currentRecord.avatarImageName,
                           points: currentRecord.gameResult,
                           date: currentRecord.date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.Game.avatarSide
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

