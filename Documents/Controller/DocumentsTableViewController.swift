//
//  DocumentsTableViewController.swift
//  Documents
//
//  Created by Dominic Pilla on 6/13/18.
//  Copyright © 2018 Dominic Pilla. All rights reserved.
//

import UIKit
import CoreData

class DocumentsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    var dateFormatter = DateFormatter()
    var displayDateFormatter = DateFormatter()
    
    var documents = [Document]()
    var filteredDocuments = [Document]()
    
    let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet weak var documentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        displayDateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm:ss a"
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Documents"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        
        do {
            documents = try managedContext.fetch(fetchRequest)
            
            documentsTableView.reloadData()
        } catch {
            print("Unable to fetch documents: " + error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // Having all of these search functions in the Controller seems to cause clutter
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "title contains[c] %@ OR contents contains[c] %@", searchText, searchText)
        
        do {
            filteredDocuments = try managedContext.fetch(fetchRequest)
        } catch {
            print("Error with filtered fetch request: \(error.localizedDescription)")
        }
        
        documentsTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredDocuments.count
        }
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentsCell", for: indexPath)
        let document : Document
        
        if isFiltering() {
            document = filteredDocuments[indexPath.row]
        } else {
            document = documents[indexPath.row]
        }
        
        if let cell = cell as? DocumentTableViewCell {
            cell.title.text = document.title
            cell.size.text = String(format: "Size: %0.0f", documents[indexPath.row].size)
            if let date = document.lastModified {
                cell.lastModified.text = "Modified: \(displayDateFormatter.string(from: date))"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteDocument(at: indexPath)
        }
    }
    
    func deleteDocument(at indexPath: IndexPath) {
        let document = documents[indexPath.row]
        
        if let managedContext  = document.managedObjectContext {
            managedContext.delete(document)
            
            do {
                try managedContext.save()
                
                self.documents.remove(at: indexPath.row)
                self.documentsTableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Deletion of document failed!")
                
                documentsTableView.reloadRows(at: [indexPath], with: .automatic)
                
            }
        }
    }
    // Segue
    @IBAction func addNewDocument(_ sender: Any) {
        performSegue(withIdentifier: "showNewDocument", sender: self)
    }
    //Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? DocumentViewController,
            let selectedRow = self.documentsTableView.indexPathForSelectedRow?.row else {
                return
        }
        
        destination.exisitingDocument = documents[selectedRow]
    }

}
