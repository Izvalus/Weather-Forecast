//
//  CurrentWeatherViewController.swift
//  Weather_Forecast
//
//  Created by Роман Мироненко on 22.10.2020.
//  Copyright © 2020 Роман Мироненко. All rights reserved.
//


import UIKit

class CurrentWeatherViewController: UIViewController {
    
    let numberFormatter = NumberFormatter()
    
    let weatherCoreDataProvider = WeatherCoreDataProvider()
    
    
    
    
    var customView: View!
    let weatherProvider = WeatherNetworkProvider()
    override func loadView() {
        customView = View()
        view = customView
    }
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        navigationItem.title = "Weather Forecast"
        customView.nameLabel.text = "Moscow"
        customView.celsiusLabel.text = "Hello"
        customView.infoLabel.text = "Forecast for the next 16 days"
        customView.goButton.setTitle(">>>", for: .normal)
        customView.goButton.addTarget(self, action: #selector(showNextController), for: .touchUpInside)
        
        weatherCoreDataProvider.get().ifSuccess { (list) in
            guard let last = list.last else {
                getCurrentWeather()
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
                getCurrentWeather()
            } else if let data = last.data,
                let informa = try? decoder.decode(Informa.self, from: data) {
                updateUI(informa: informa)
            }
        }
        numberFormatter.maximumFractionDigits = 1
    }
    
    @objc func showNextController() {
        navigationController?.pushViewController(WeatherForcastListViewController(), animated: true)
    }
    
    func getCurrentWeather() {
        weatherProvider.currentWeather { [weak self] (response: Result<Informa, NetworkClient.Error>) in
            response
                .ifSuccess {
                    self?.weatherCoreDataProvider.save(informa: $0)
                    self?.updateUI(informa: $0)
                }
                .ifError{ print($0) }
        }
    }
    
    func updateUI(informa: Informa) {
        UIView.animate(withDuration: 1.5, animations: {
            self.customView?.celsiusLabel.alpha = 1
        })
        let temp = NSNumber(value: informa.main.temp ?? 0)
        customView?.celsiusLabel.text = (numberFormatter.string(from: temp) ?? "") + " С°"
        customView?.nameLabel.text = "\(informa.name)"
    }
}

extension CurrentWeatherViewController {
    class View: UIView {
        
        let nameLabel = setup(UILabel()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .black
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        }
        
        let celsiusLabel = setup(UILabel()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .black
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            $0.alpha = 0
        }
        
        let infoLabel = setup(UILabel()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .black
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        }
        
        let goButton = setup(UIButton()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.textAlignment = .center
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        }
        
        init() {
            super.init(frame: .zero)
            backgroundColor = .lightGray
            
            addSubview(nameLabel)
            addSubview(celsiusLabel)
            addSubview(infoLabel)
            addSubview(goButton)
            setupConstraints()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupConstraints() {
            NSLayoutConstraint.activate([
                nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                
                celsiusLabel.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -50),
                celsiusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                
                infoLabel.leftAnchor.constraint(equalTo: leftAnchor),
                infoLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
                infoLabel.widthAnchor.constraint(equalToConstant: 300),
                
                goButton.leadingAnchor.constraint(equalTo: infoLabel.trailingAnchor),
                goButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                goButton.centerYAnchor.constraint(equalTo: infoLabel.centerYAnchor)
                
                ])
        }
    }
}
