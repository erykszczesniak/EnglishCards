//
//  WordsVC.swift
//  Cards
//
//  Created by Eryk Szcześniak on 10/08/2020.
//  Copyright © 2020 Eryk Szcześniak. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

import UIKit

class WordsVC: SwipeTableViewController {

      @IBOutlet weak var searchBar: UISearchBar!
        
        var wordsToLearn: Results<Word>?
        let realm = try! Realm()
       

        var selectedCategory: Category? {
            didSet {
                loadItems()
            }
        }
    
        
        override func viewDidLoad() {
            
            print(Realm.Configuration.defaultConfiguration.fileURL)

            super.viewDidLoad()
            tableView.separatorStyle = .none
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            
            if let colourHex = selectedCategory?.colour {
                title = selectedCategory!.name
                guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
                }
                if let navBarColour = UIColor(hexString: colourHex) {
                    //Original setting: navBar.barTintColor = UIColor(hexString: colourHex)
                    //Revised for iOS13 w/ Prefer Large Titles setting:
                    navBar.backgroundColor = navBarColour
                    navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                    searchBar.barTintColor = navBarColour
                }
            }
        }
        
        //Mark - Tableview Datasource Methods
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return wordsToLearn?.count ?? 1
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if let item = wordsToLearn?[indexPath.row] {
                cell.textLabel?.text = item.title
                if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(wordsToLearn!.count)) {
                    cell.backgroundColor = colour
                    cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
                }
                cell.accessoryType = item.done ? .checkmark : .none
            } else {
                cell.textLabel?.text = "No Words Added"
            }
            
            return cell
        }
        
        //Mark - TableView Delegate Methods
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            if let item = wordsToLearn?[indexPath.row] {
                do {
                    try realm.write{
                        // realm.delete(item)
                        item.done = !item.done
                    }
                } catch {
                    print("Error saving done status, \(error)")
                }
            }
            
            tableView.reloadData()
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
            
            var textField = UITextField()
            let alert = UIAlertController(title: "Add New Word", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Add Word", style: .default) { (action) in
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Word()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.words.append(newItem)
                        }
                    } catch {
                        print("Error saving new words, \(error)")
                    }
                }
                self.tableView.reloadData()
            }
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Create new word"
                textField = alertTextField
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        
        //Mark - Model Manipulation Methods
        func loadItems() {
            wordsToLearn = selectedCategory?.words.sorted(byKeyPath: "title", ascending: true)
            tableView.reloadData()
        }
        
        override func updateModel(at indexPath: IndexPath) {
            if let item = wordsToLearn?[indexPath.row] {
                do {
                    try realm.write{
                        realm.delete(item)
                    }
                } catch {
                    print("Error deleting word, \(error)")
                }
            }
        }
    }


        
        
    
