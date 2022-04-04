//
//  InfoMenuViewController.swift
//  GriDot
//
//  Created by 박찬울 on 2022/04/04.
//

import UIKit

class InfoMenuViewController: UIViewController {
    @IBOutlet weak var MenuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension InfoMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTabelViewCell", for: indexPath) as? ProfileTabelViewCell else { return UITableViewCell() }
        return cell
    }
}

class ProfileTabelViewCell: UITableViewCell {
    
}
