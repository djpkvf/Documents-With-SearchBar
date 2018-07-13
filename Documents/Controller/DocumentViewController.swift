//
//  DocumentViewController.swift
//  Documents
//
//  Created by Dominic Pilla on 6/14/18.
//  Copyright © 2018 Dominic Pilla. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    
    var exisitingDocument: Document?
    
    @IBOutlet weak var documentTitle: UITextField!
    @IBOutlet weak var documentContents: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.text = exisitingDocument?.title
        contentsTextView.text = exisitingDocument?.contents
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveDocument(_ sender: Any) {
        
        // Check if the textboxes are empty.  If so, do not save the document
        if let title = titleTextField.text, let contents = contentsTextView.text, !title.isEmpty, !contents.isEmpty {
            let size = Double(contents.count) // Size calculated on amount of characters in contents
            let currentDate = Date() // Date for last modified
            
            var document: Document?
            
            if let existingDocument = exisitingDocument {
                exisitingDocument?.title = title
                exisitingDocument?.contents = contents
                existingDocument.lastModified = currentDate
                existingDocument.size = size
                
                document = exisitingDocument
            } else {
                document = Document(title: title, contents: contents, lastModified: currentDate, size: size)
            }
            
            if let document = document {
                do {
                    guard let managedContext = document.managedObjectContext else { return }
                    
                    if managedContext.hasChanges {
                        try managedContext.save()
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch {
                    print("Document could not be saved.")
                }
            }
        }
    }
    
    @IBAction func textFieldEdited(_ sender: Any) {
        self.title = documentTitle.text
    }
}
