//
//  ViewController.swift
//  ToDoApp
//
//  Created by 유현이 on 2022/09/22.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    
    var doneButton: UIBarButtonItem?
    
    var datas = [Data]() {
        didSet {
            self.saveDatas()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        loadDatas()
        doneButtonSetup()
    }
    
    func doneButtonSetup() {
        self.doneButton = UIBarButtonItem(title: "닫기", style: .done, target: self, action: #selector(doneButtonTapped))
        doneButton?.tintColor = .darkGray

    }
    
    @objc func doneButtonTapped() {
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated: true)
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func saveDatas() {
        let data = datas.map {
            [
                "title": $0.title,
                "done" : $0.done
        
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "datas")
    }
    
    func loadDatas() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "datas") as? [[String: Any]] else { return }
        self.datas = data.compactMap{
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool  else {return nil}
            return Data(title: title, done: done)
        }
    }

    @IBAction func editButtonNav(_ sender: UIBarButtonItem) {
        guard !self.datas.isEmpty else { return }
        self.navigationItem.leftBarButtonItem = doneButton
        self.tableView.setEditing(true, animated: true)

    }

    @IBAction func addButtonNav(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "할 일 목록", message: nil, preferredStyle: .alert)
        let alertAddButton = UIAlertAction(title: "등록", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text else { return }
            let data = Data(title: title, done: false)
            self?.datas.append(data)
            self?.tableView.reloadData()
        }
        
        let alertCancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(alertCancelButton)
        alert.addAction(alertAddButton)
        alert.addTextField { textField in
            textField.placeholder = "할 일을 입력해주세요."
        }
        
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        let data = datas[indexPath.row]
        cell.textLabel?.text = data.title
        if data.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.datas.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if self.datas.isEmpty {
            self.doneButtonTapped()
        }
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var datas = self.datas
        let data = datas[sourceIndexPath.row]
        datas.remove(at: sourceIndexPath.row)
        datas.insert(data, at: destinationIndexPath.row)
        self.datas = datas
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var data = self.datas[indexPath.row]
        data.done = !data.done
        self.datas[indexPath.row] = data
        tableView.reloadRows(at: [indexPath], with: .automatic)

    }
}
