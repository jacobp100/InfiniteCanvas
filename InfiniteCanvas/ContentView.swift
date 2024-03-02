//
//  ContentView.swift
//  InfiniteCanvas
//
//  Created by Jacob Parker on 02/03/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        InfiniteCanvasView()
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
