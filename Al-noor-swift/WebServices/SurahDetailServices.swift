//
//  SurahDetailServices.swift
//  Al-noor-swift
//
//  Created by Mansour Mahamat-salle on 23/04/2024.
//

import Foundation
import SwiftUI
import Combine

class SurahDetailServices : ObservableObject{
    @Published var surahDetail : [Ayahs] = []
    
    func getSurah(surahId : Int){
    
        guard let url = URL(string: "https://api.alquran.cloud/v1/surah/\(surahId)/ar.alafasy") else{
            fatalError("Fatal Error")
        }
        
        
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
         
            guard let response = response as? HTTPURLResponse else{
                return
            }
          
            if response.statusCode == 200{
                guard let data = data else {
                    return
                }

                DispatchQueue.main.async {
                    do{
                        let jsonDecoder = try JSONDecoder().decode(SurahDetailModel.self, from: data)
                        
                        self.surahDetail = jsonDecoder.data.ayahs
                    }catch{
                        print("error decoding", error)
                    }
                }
            }
            
            
        }.resume()

    }
    
    
   
}
