//
//  ViewController.swift
//  Experimentation+Combine
//
//  Created by Jullianm on 23/11/2019.
//  Copyright © 2019 Jullianm. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController {
    var viewModel: ViewModel!
    var subscriptions = Set<AnyCancellable>()
    var dataSource: TableViewDatasource!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        viewModel = .init(service: .webservice)
        dataSource = .init(tableView: tableView)
        
        setupTableView()
        setupBindings()
    }
    
    private func setupTableView() {
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "Cell")
    }
    
    func setupBindings() {
        viewModel.output.didReceiveData
            .replaceError(with: [])
            .assign(to: \.posts, on: dataSource)
            .store(in: &subscriptions)
        
        viewModel.output.didReceiveResponse
            .sink(receiveCompletion: { completion in
                guard case let .failure(error) = completion else {
                    return
                }
                print(error)
            }, receiveValue: { statusCode in
                print(statusCode)
            }).store(in: &subscriptions)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.input.didSelectModel.send(dataSource.posts[indexPath.item])
    }
}
