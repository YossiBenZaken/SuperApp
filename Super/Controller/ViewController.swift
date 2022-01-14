//
//  ViewController.swift
//  Super
//
//  Created by Yosef Ben Zaken on 08/01/2022.
//

import UIKit
import Firebase
import ChameleonFramework

class ViewController: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet weak var product: UITextField!
    @IBOutlet weak var quantity: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    var products: [Product] = []
    let categories = ["ירקות","ניקיון","חד פעמי","דגנים","שימורים","קטניות","קצביה","דגים","קפואים","מאפיה","שתייה","מקררים","שונות"]
    let colors = [HexColor("#55efc4"),HexColor("#81ecec"),HexColor("#74b9ff"),HexColor("#ffeaa7"),HexColor("#fab1a0"),HexColor("#9AECDB"),HexColor("#D6A2E8"),HexColor("#BDC581"),HexColor("#d63031"),HexColor("#0984e3"),HexColor("#fd79a8"),HexColor("#636e72"),HexColor("#00a8ff")]
    var selectedCategory = "ירקות"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        initData()
    }
    func initData() {
        product.placeholder = "שם המוצר"
        quantity.placeholder = "כמות"
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        categoryPicker.selectRow(0, inComponent: 0, animated: true)
        db.collection("products").addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Error gettings documents: \(err)")
            } else {
                self.products = []
                for document in querySnapshot!.documents {
                    let quantity: String = document.data()["quantity"] as! String
                    let product: String = document.data()["product"] as! String
                    let category: String = document.data()["category"] as! String
                    self.products.append(Product(product: product, quantity: quantity, documentId: document.documentID,category: category))
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let productVC = segue.destination as! ProductViewController
        let selectedRow = tableView.indexPathForSelectedRow!.row
        productVC.titleBar = categories[selectedRow]
        productVC.color = colors[selectedRow]!
        productVC.products = products.filter({ product in
            product.category == categories[selectedRow]
        })
    }
    @IBAction func addToCart(_ sender: Any) {
        var ref: DocumentReference? = nil
        let pr = products.filter { p in
            return p.product == product.text
        }
        if !pr.isEmpty {
            let curProductQuantity = Int(pr.first!.quantity)!
            let prevProductQuantity = Int(quantity.text!)!
            let value = curProductQuantity + prevProductQuantity
            db.collection("products").document(pr.first!.documentId)
                .updateData(["quantity" : String(value)], completion: { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        self.product.text = ""
                        self.quantity.text = ""
                    }
                })
        } else {
            ref = db.collection("products").addDocument(data: [
                "product": product.text!,
                "quantity": quantity.text!,
                "category": selectedCategory
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    self.product.text = ""
                    self.quantity.text = ""
                }
            }
        }
    }
}

extension ViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
}
class CategoryCellView: UITableViewCell {
    @IBOutlet weak var circleColor: UIImageView!
}
extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCellView
        cell.textLabel?.text = categories[indexPath.row]
        cell.circleColor.tintColor = colors[indexPath.row%colors.count]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "productList", sender: self)
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
