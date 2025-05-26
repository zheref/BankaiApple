//
//  OnUpdateModifier.swift
//  BankaiApple
//
//  Created by Sergio Daniel on 17/12/24.
//

import SwiftUI
import Combine

struct OnUpdateModifier<V>: ViewModifier where V: Equatable {
    
    let value: V
    let publisher: AnyPublisher<V, Never>
    let action: (_ oldValue: V, _ newValue: V) -> Void
    
    var lastValue: V
    
    public func body(content: Content) -> some View {
        #if os(macOS)
        if #available(macOS 14.0, *), OSEnv.isAtLeast(.sonoma) {
            content
                .onChange(of: value) { action($0, $1) }
        } else {
            content
                .onReceive(publisher) {
                    action(lastValue, $0)
                }
        }
        #else
        content
            .onReceive(publisher) {
                action(lastValue, $0)
            }
        #endif
    }
    
}

extension View {
    
    public func onUpdate<V>(of value: V,
                            initialValue: V,
                            publisher: AnyPublisher<V, Never>,
                            action: @escaping(_ oldValue: V, _ newValue: V) -> Void) -> some View where V : Equatable {
        modifier(
            OnUpdateModifier(
                value: value,
                publisher: publisher,
                action: action,
                lastValue: initialValue
            )
        )
    }
    
}

