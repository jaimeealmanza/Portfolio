// 
// Binding-OnChange.swift of Portfolio.
// Created by JaimeAlmanza on 02/11/20.
//
// 


import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}
