//
//  ViewController.swift
//  Test
//
//  Created by Duong Bao Long on 10/11/21.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    var project = Projects.main
    
    @IBOutlet weak var tbview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: Notification.Name(Projects.projectDidLoadKey), object: nil, queue: nil) { _ in
            self.tbview.reloadData()
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: add button
    @IBAction func addButtonPressed(_ sender: UIButton) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new project", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newItem = Project(id: UUID().uuidString, name: textField.text!)
            newItem.name = textField.text!
            self.project.projects.append(newItem)
            self.tbview.reloadData()
        }
        alert.addTextField { (alertAddTextField) in
            alertAddTextField.placeholder = "Create new project"
            textField = alertAddTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
}

//MARK: ViewController Extension

extension ViewController: UITableViewDataSource, ProjectTableViewCellDelegate  {
    func cellDelete(_ cell: ProjectTableViewCell) {
        guard let index = tbview.indexPath(for: cell)?.row else{
            return
        }
        
        project.projects.remove(at: index)
        tbview.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
    }
    
    func cellTap(_ cell: ProjectTableViewCell) {
        guard let index = tbview.indexPath(for: cell)?.row,
              let screnTwo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryView") as? ViewGalleryController,
                let navigation = navigationController
        else {
            
            return
        }
        screnTwo.project = project.projects[index]
        navigation.pushViewController(screnTwo, animated: true)
        print(index)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return project.projects.count ?? 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifer, for: indexPath)
        guard let cell = cell1 as? ProjectTableViewCell else {
            return cell1
        }
        
        cell.textName.text = project.projects[indexPath.row].name
        cell.delegate = self
//        self.navigationController?.pushViewController(, animated: true)
        return cell
    }
    
}




