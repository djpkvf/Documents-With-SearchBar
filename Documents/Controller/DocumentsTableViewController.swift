//
//  DocumentsTableViewController.swift
//  Documents
//
//  Created by Dominic Pilla on 6/13/18.
//  Copyright © 2018 Dominic Pilla. All rights reserved.
//

import UIKit
import CoreData

class DocumentsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dateFormatter = DateFormatter()
    var displayDateFormatter = DateFormatter()
    
    var documents = [Document]()
    
    @IBOutlet weak var documentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        displayDateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm:ss a"
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentsCell", for: indexPath)
        let document = documents[indexPath.row]
        
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

    @IBAction func addNewDocument(_ sender: Any) {
        performSegue(withIdentifier: "showNewDocument", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? DocumentViewController,
            let selectedRow = self.documentsTableView.indexPathForSelectedRow?.row else {
                return
        }
        
        destination.exisitingDocument = documents[selectedRow]
    }

}
