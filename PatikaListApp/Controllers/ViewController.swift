//
//  ViewController.swift
//  PatikaListApp
//
//  Created by Burak AÇIK on 9.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = [NSManagedObject]()
    var alertController = UIAlertController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetch()
        
    }


    @IBAction func didRemoveBarButtonItemTapped(_ sender: Any) {
        presentAlert(title: "Uyarı!",
                     message: "Listedeki bütün öğeleri silmek istediğinize emin misiniz?",
                     defaultButtonTitle: "Evet",
                     cancelButtonTitle: "Vazgeç") { _ in
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            for item in self.data {
                managedObjectContext?.delete(item)
            }
            
            try? managedObjectContext?.save()
            
            self.fetch()
        }
        
    }
    
    @IBAction func didAddBarButtonItemTapped(_ sender: Any) {
        presentAddAlert()
    }
    
    
    func presentAddAlert() {
        presentAlert(title: "Yeni Eleman Ekle",
                     message: nil,
                     defaultButtonTitle: "Ekle",
                     cancelButtonTitle: "Vazgeç",
                     isTextFieldAvailable: true,
                     defaultButtonHandler: { _ in
            let text = self.alertController.textFields?.first?.text
            if text != "" {
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem",
                                                        in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!,
                                               insertInto: managedObjectContext)
                
                listItem.setValue(text, forKey: "title")
                
                try? managedObjectContext?.save()
                
                self.fetch()
            } else {
                self.presentWarningAlert()
            }
        })
    }
    
    
    func presentWarningAlert() {
        presentAlert(title: "Uyarı!",
                     message: "Liste eleman boş olamaz",
                     cancelButtonTitle: "Tamam")
    }
    
    
    func presentAlert(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      defaultButtonTitle: String? = nil,
                      cancelButtonTitle: String?,
                      isTextFieldAvailable: Bool = false,
                      defaultButtonHandler: ((UIAlertAction) -> Void)? = nil) {
        
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: preferredStyle)
        
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default,
                                              handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        if isTextFieldAvailable {
            alertController.addTextField()
        }
        
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
    }
    
    
    func fetch() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Sil") { _, _, _ in
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            managedObjectContext?.delete(self.data[indexPath.row])
            
            try? managedObjectContext?.save()
            
            self.fetch()
            
        }
        
        let editAction = UIContextualAction(style: .normal,
                                            title: "Düzenle") { _, _, _ in
            self.presentAlert(title: "Eleman Düzenle",
                              message: "'\(self.data[indexPath.row].value(forKey: "title")!)'", //Eleman düzenleme alert ekranında düzenlenecek elemanı gösterir
                              defaultButtonTitle: "Düzenle",
                              cancelButtonTitle: "Vazgeç",
                              isTextFieldAvailable: true,
                              defaultButtonHandler: { _ in
                let text = self.alertController.textFields?.first?.text
                if text != "" {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if managedObjectContext!.hasChanges {
                        try? managedObjectContext?.save()
                    }
                    
                    self.tableView.reloadData()
                } else {
                    self.presentWarningAlert()
                }
            })
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return config
    }
    
}
 
