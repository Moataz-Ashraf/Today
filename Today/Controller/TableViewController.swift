//
//  TableViewController.swift
//  Today
//
//  Created by Moataz on 9/27/19.
//  Copyright © 2019 Moataz. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class TableViewController: UITableViewController {

    
    //variable
          let Context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemArray:Array = [Item]()
    var SelectedCategory : Category? {
        didSet{
            LoadItems()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
   
    }
    override func viewWillAppear(_ animated: Bool) {
        if let navColor = SelectedCategory?.colors{
            
            title = SelectedCategory?.name
            
            guard let navBar = navigationController?.navigationBar else{fatalError("Navigation Bar Not Found")}
            
            if  let color = HexColor(navColor){
            navBar.barTintColor = color
            navBar.tintColor = ContrastColorOf(color, returnFlat: true)
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(color, returnFlat: true)]
            
                
               // ContrastColorOf(color, returnFlat: true)
            
            }
            
        }
    }

    // MARK: - Table view data source

    // Methods DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IdCell", for: indexPath)as! SwipeTableViewCell
        cell.delegate = self
        let color = (HexColor(SelectedCategory?.colors ?? "#1ABC9C"))! .darken(byPercentage:CGFloat(indexPath.row)/CGFloat(itemArray.count) )
        cell.backgroundColor = color
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.textLabel?.textColor = ContrastColorOf(color!, returnFlat: true)

        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        return cell
    }
    //*******************************Method Delegate**********************
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(itemArray[indexPath.row].title!)
       // itemArray[indexPath.row].setValue("", forKey: "title")
       // Context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
       itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        self.SaveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       
    }
    
    //*********************Button Add New textField************************
    
    @IBAction func AddNewCell(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let Alert = UIAlertController(title: "Add New Today Item", message: "", preferredStyle: .alert)
        
        let Action = UIAlertAction(title: "Add Item", style: .default) { (action) in
           
       
            let newItem = Item(context: self.Context )
         //
           newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.SelectedCategory
            self.itemArray.append(newItem)
            self.SaveItems()
           // self.tableView.reloadData()
        }
        Alert.addTextField { (MyTextField) in
            MyTextField.placeholder = "Create New Item "
            textField = MyTextField
        }
        Alert.addAction(Action)
        present(Alert, animated: true, completion: nil)
    }
    
    // MARK:-   Method Save & Load

    func SaveItems() {
        do {
            try Context.save()
        }
        catch {
            print("Error  is \(error)")
            
        }
        self.tableView.reloadData()
    }
    
    func LoadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(),predicate : NSPredicate? = nil) {
       let CategoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", SelectedCategory!.name!)
        if let addetionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [CategoryPredicate,addetionalPredicate])
            
        }else{
            request.predicate = CategoryPredicate
        }
        
        do{
      itemArray = try Context.fetch(request)
        }
        catch{
            print("Error is \(error)")
        }
        self.tableView.reloadData()
    }
    
   
    
}
extension TableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicates =  NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
       
        request.sortDescriptors = [NSSortDescriptor(key:"title", ascending: true)]
        print(searchBar.text!)
        LoadItems(with: request ,predicate: predicates )
       
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            LoadItems()
            DispatchQueue.main.async {
                
            }
            searchBar.resignFirstResponder()
        }
    }
}
extension TableViewController : SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            
            do{
                try self.Context.delete(self.itemArray[indexPath.row])
                self.itemArray.remove(at:indexPath.row)
                try self.Context.save()
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
