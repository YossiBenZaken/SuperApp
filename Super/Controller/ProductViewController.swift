//
//  ProductViewController.swift
//  Super
//
//  Created by Yosef Ben Zaken on 14/01/2022.
//

import UIKit
import Firebase

class ProductViewController: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet weak var tableView: UITableView!
    var products: [Product] = []
    var titleBar: String = "";
    var color: UIColor = UIColor.white
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        title = titleBar
        navigationController?.navigationBar.standardAppearance.backgroundColor = color
    }
}
class CellView: UITableViewCell {
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var quantity: UILabel!
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension ProductViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! CellView
        cell.productName.text = products[indexPath.row].product
        cell.quantity.text = String(products[indexPath.row].quantity)
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "מחק") { ac, view, success in
            let documentId = self.products[indexPath.row].documentId
            self.db.collection("products").document(documentId).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    self.products = self.products.filter { p in
                        p.documentId != documentId
                    }
                    tableView.reloadData()
                    
                }
            }
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
