//
//  bountyListViewController.swift
//  reBountyList
//
//  Created by 박찬울 on 2021/02/09.
//

import UIKit

class BountyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    let name = ["brook", "chopper", "franky", "luffy", "nami", "robin", "sanji", "zoro"]
    let bounty = [100000, 3000000, 5500, 66000000, 12300000, 400000, 880000, 10]
    
    // 셀 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bounty.count
    }
    
    // 셀 표현
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableCell else {
            return UITableViewCell()
        }
        
        let img = UIImage(named: "\(name[indexPath.row]).jpg")
        cell.imgView.image = img
        cell.nameLabel.text = name[indexPath.row]
        cell.bountyLabel.text = "\(bounty[indexPath.row])"
        
        
        return cell
    }
    
    // UITabelViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("--> \(indexPath.row)")
    }
}

class TableCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bountyLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
}
