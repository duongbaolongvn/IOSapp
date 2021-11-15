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

        let alert = UIAlertController(title: "Add new project", message: "", preferredStyle: .alert)
        alert.addTextField { (UITextField) in
            UITextField.placeholder = "Add new project"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default) { (action) in
            guard let text = alert.textFields?.first,
                  let name = text.text else {return}
            if name == "" {
                self.present(alert, animated: true, completion: nil)
            }else {
                self.project.addProject(name)
                self.tbview.insertRows(at: [IndexPath(item: self.project.projects.count - 1, section: 0)], with: .automatic)
            }
            
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return project.projects.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifer, for: indexPath)
        guard let cell = cell1 as? ProjectTableViewCell else {
            return cell1
        }
        
        cell.textName.text = project.projects[indexPath.row].name
        cell.delegate = self
        return cell
    }
    
}




