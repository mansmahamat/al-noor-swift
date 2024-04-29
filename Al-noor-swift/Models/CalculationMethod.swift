//
//  CalculationMethod.swift
//  Al-noor-swift
//
//  Created by Mansour Mahamat-salle on 28/04/2024.
//
import Adhan

extension CalculationMethod {
    // Function to get CalculationParameters for a given method string
    static func parameters(for methodName: String) -> CalculationParameters? {
        guard let method = CalculationMethod(rawValue: methodName) else {
            return nil
        }
        
        return method.params
    }
}
