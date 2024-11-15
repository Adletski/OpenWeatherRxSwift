//
//  Weather.swift
//  OpenWeatherApp
//
//  Created by Adlet Zhantassov on 15.11.2024.
//

import Foundation

struct WeatherResult: Codable {
    let main: Weather
}

extension WeatherResult {
    static var empty: WeatherResult {
        return WeatherResult(main: Weather(temp: 0.0, humidity: 0.0))
    }
}

struct Weather: Codable {
    let temp: Double
    let humidity: Double
}
