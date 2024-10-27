//
//  WeatherManager.swift
//  Clima
//
//  Created by Роман Каменский on 09.08.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didWeatherUpdate(_ weatherManager: WeatherManager, weather: WeatherModel)
    
    func didWithErrorFail(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=7fbcbe374af7e624756feceb8d7d88a0&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequesr(with: urlString)
    }
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequesr(with: urlString)
    }
    
    func performRequesr(with urlString: String) {
        //1. create url
        if let url = URL(string: urlString){
            //2. Create URLsesion
            let session = URLSession(configuration: .default)
            
            //3. Give a session task
            let task = session.dataTask(with: url) { data, responce, error in
                if error != nil{
                    delegate?.didWithErrorFail(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = parseJSON(safeData){
                        delegate?.didWeatherUpdate(self, weather: weather)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
            
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatheDate.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch{
            delegate?.didWithErrorFail(error: error) 
            return nil
        }
        
    }
    
   
    
}
