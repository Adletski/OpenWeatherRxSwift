//
//  ViewController.swift
//  OpenWeatherApp
//
//  Created by Adlet Zhantassov on 15.11.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .map({ self.textField.text })
            .subscribe { city in
                if let city = city {
                    self.fetchWeather(by: city)
                } else {
                    self.displayWeather(nil)
                }
            }.disposed(by: disposeBag)
    }
    
    private func fetchWeather(by city: String) {
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL.urlForWeatherAPI(city: cityEncoded) else { return }
        
        let resource = Resource<WeatherResult>(url: url)
        
//        let search = URLRequest.load(resource: resource)
//            .observe(on: MainScheduler.instance)
//            .asDriver(onErrorJustReturn: WeatherResult.empty)
        
        let search = URLRequest.load(resource: resource)
            .observe(on: MainScheduler.instance)
            .retry(3)
            .catch { error in
                print(error.localizedDescription)
                return Observable.just(WeatherResult.empty)
            }.asDriver(onErrorJustReturn: WeatherResult.empty)
        
        search.map { "\($0.main.temp)" }
            .drive(self.weatherLabel.rx.text)
            .disposed(by: disposeBag)
        
        search.map { "\($0.main.humidity)" }
            .drive(self.humidityLabel.rx.text)
            .disposed(by: disposeBag)
    }

    private func displayWeather(_ weather: Weather?) {
        if let weather = weather {
            self.weatherLabel.text = "\(weather.temp) 🥱"
            self.humidityLabel.text = "\(weather.humidity) 💦"
        } else {
            self.weatherLabel.text = "❌"
            self.humidityLabel.text = "⛔️"
        }
    }
}

