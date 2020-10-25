//
//  WeatherForcastListViewController.swift
//  Weather_Forecast
//
//  Created by Роман Мироненко on 22.10.2020.
//  Copyright © 2020 Роман Мироненко. All rights reserved.
//


import UIKit

final class WeatherForcastListViewController: UIViewController {
    
    let weatherCoreDataProvider = WeatherCoreDataProvider()
    
    var historyWeatherForcast: HistoryWeatherForcast?
    
    var customView: View!
    
    let weatherProvider = WeatherNetworkProvider()
    
    let dateFormatter = DateFormatter()
    
    let measurementFormatter = MeasurementFormatter()
    
    override func loadView() {
        customView = View()
        view = customView
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        customView.tableView.dataSource = self
        customView.tableView.delegate = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        customView.tableView.refreshControl = refreshControl
        measurementFormatter.numberFormatter.maximumFractionDigits = 1
        
        weatherCoreDataProvider.getForcast().ifSuccess { (list) in
            guard let last = list.last else {
                loadData()
                return
            }
            let calendar = Calendar.current
            let components = calendar.dateComponents(
                [.second],
                from: last.create ?? Date(),
                to: Date()
            )
            let decoder = JSONDecoder()
            if components.second ?? 0 >= 500 {
                loadData()
            } else if let data = last.data, let history = try? decoder.decode(HistoryWeatherForcast.self, from: data) {
            historyWeatherForcast = history
            customView?.tableView.reloadData()
            }
        }
    }
    
    @objc func loadData() {
        weatherProvider.weatherForcast(count: 16) { [weak customView, weak self] (response: Result<HistoryWeatherForcast, NetworkClient.Error>) in
            response
                .ifSuccess {
                    self?.weatherCoreDataProvider.save(history: $0)
                    self?.historyWeatherForcast = $0
                    customView?.tableView.reloadData()
                    customView?.tableView.refreshControl?.endRefreshing()
                }
                .ifError{_ in }
        }
    }
}


extension WeatherForcastListViewController {
    class View: UIView {
        
        let tableView = setup(UITableView()) {
            $0.tableFooterView = UIView()
            $0.register(WeatherForcastListViewController.Cell.self, forCellReuseIdentifier: "Cell")
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
        init() {
            super.init(frame: .zero)
            backgroundColor = .lightGray
            
            addSubview(tableView)
            setupConstraints()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupConstraints() {
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
                ])
        }
    }
    
}

extension WeatherForcastListViewController {
    final class Cell: UITableViewCell {
        let numberLabel = setup(UILabel()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let nameLabel = setup(UILabel()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let celsiusLabel = setup(UILabel()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let stackView = setup(UIStackView()) {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .equalSpacing
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.addSubview(stackView)
            stackView.addArrangedSubview(numberLabel)
            stackView.addArrangedSubview(nameLabel)
            stackView.addArrangedSubview(celsiusLabel)
            setupConstraint()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupConstraint() {
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                
                numberLabel.widthAnchor.constraint(equalToConstant: 100),
                nameLabel.widthAnchor.constraint(equalToConstant: 100),
                celsiusLabel.widthAnchor.constraint(equalToConstant: 100)
                ])
        }
    }
}

extension WeatherForcastListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyWeatherForcast?.list.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WeatherForcastListViewController.Cell
        let element = historyWeatherForcast?.list[indexPath.row]
        cell.nameLabel.text = "Moscow"
        cell.celsiusLabel.text = element.map{
            let measurement = Measurement(value: $0.temp.day, unit: UnitTemperature.celsius)
            return measurementFormatter.string(from: measurement)
        }
        cell.numberLabel.text = element.map{
            dateFormatter.dateFormat = "dd.MM.YYYY"
            return dateFormatter.string(from: Date(timeIntervalSince1970: Double($0.dt)))
        }
        return cell
    }
}

