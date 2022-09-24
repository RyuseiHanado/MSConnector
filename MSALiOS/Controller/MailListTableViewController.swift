import UIKit

class MailListTableViewController: UITableViewController {
    
    var reloadButton: UIBarButtonItem!
    
    let msgraphManager = MSGraphManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("MailListTableViewController is viewDidLoad")
        
        msgraphManager.getMailList {
            print("clousure!!!!")
            self.tableView.reloadData()
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // UI
        reloadButton = UIBarButtonItem(title: "更新", style: .done, target: self, action: #selector(loadMailData(_:)))
        self.navigationItem.rightBarButtonItem = reloadButton
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Account.mailList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = Account.mailList[indexPath.row].subject
        
        return cell
    }
    
    @objc func loadMailData(_ sender: UIButton) {
        msgraphManager.getMailList {
            print("clousure!!!!")
            self.tableView.reloadData()
        }
    }
    
    @objc func sendMail(_ sender: UIButton) {
        msgraphManager.getMailList {
            print("clousure!!!!")
            self.tableView.reloadData()
        }
    }
    
    
    // いずれかの行が選択された際にトリガされるメソッド
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(Account.mailList[indexPath.row].subject)
        
        // 選択状態を解除する（灰色状態をすぐに解除）
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
