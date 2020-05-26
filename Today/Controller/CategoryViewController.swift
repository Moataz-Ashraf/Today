//
//  CategoryViewController.swift
//  Today
//
//  Created by Moataz on 9/28/19.
//  Copyright © 2019 Moataz. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: UITableViewController {
    
    var Categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        LoadCategory()
       
    }

    // MARK: - TableView dataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Categories.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        let color = HexColor(Categories[indexPath.row].colors!)

       // let cuColor = UIColor.randomFlat
        cell.backgroundColor = color
        
        cell.textLabel?.text = Categories[indexPath.row].name
        cell.textLabel?.textColor = ContrastColorOf(color!, returnFlat: true)

        
       
        return cell
    }
    // MARK: -tableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TableViewController
        if let indexPath = tableView.indexPathForSelectedRow {
    destinationVC.SelectedCategory = Categories[indexPath.row]
    }
    }
    //MARK: -Button Add New Category
    
    @IBAction func AddBuCategory(_ sender: UIBarButtonItem) {
        var textFields = UITextField()
        
        let Alert = UIAlertController(title: "Add Categories ", message: "", preferredStyle: .alert)
        
        let Action = UIAlertAction(title: "Add New Category", style: .default) {
            (action) in
            let newCategory = Category(context: self.context )
            newCategory.name = textFields.text!
            newCategory.colors = UIColor.hexValue(UIColor.randomFlat)()
            self.Categories.append(newCategory)
            self.SaveCategory()
        }
        
        Alert.addAction(Action)
        
        Alert.addTextField {
            (txtField) in
            textFields = txtField
            textFields.placeholder = "Add New Category"
        }
        
        present(Alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Save & Load Methods
    func  SaveCategory() {
        do{
            try context.save()
        }
        catch{
            print(error)
        }
        tableView.reloadData()
    }
    
    //LoadCategory Method
    func LoadCategory() {
        let request :NSFetchRequest<Category> = Category.fetchRequest()
        do{
          Categories =  try context.fetch(request)
        }catch{
            print(error)
        }
        tableView.reloadData()
    }
}
extension CategoryViewController : SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            
            do{
                try self.context.delete(self.Categories[indexPath.row])
                self.Categories.remove(at:indexPath.row)
                try self.context.save()
            }
            catch{
                print(error)
            }
            
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "Trash")

        
        return [deleteAction]
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
       // options.transitionStyle = .border
        return options
    }
}
