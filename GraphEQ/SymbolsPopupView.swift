//
//  SymbolsPopupView.swift
//  GraphEQ
//
//  Created by Ashley Gray on 7/30/25.
//

import SwiftUI

struct SymbolsPopupView: View {
    @EnvironmentObject var viewModel: GraphViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("Math Symbols")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                        .shadow(color: .cyan.opacity(0.8), radius: 8)
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(MathSymbol.allCases, id: \.self) { symbol in
                                Button(symbol.display) {
                                    viewModel.insertSymbol(symbol)
                                    dismiss()
                                }
                                .buttonStyle(SymbolButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
    }
}

#Preview {
    SymbolsPopupView()
        .environmentObject(GraphViewModel())
} 