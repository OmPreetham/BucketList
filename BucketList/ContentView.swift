//
//  ContentView.swift
//  BucketList
//
//  Created by Om Preetham Bandi on 6/23/24.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()
    
    let startingLocation = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 56, longitude: -3), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)))
        
    var body: some View {
        ZStack {
            if viewModel.isUnlocked {
                VStack {
                    MapReader { proxy in
                        Map(initialPosition: startingLocation) {
                            ForEach(viewModel.locations) { location in
                                Annotation(location.name, coordinate: location.coordinate) {
                                    Image(systemName: "star.circle")
                                        .resizable()
                                        .foregroundStyle(.red)
                                        .frame(width: 44, height: 44)
                                        .background(.white)
                                        .clipShape(.circle)
                                        .onLongPressGesture {
                                            viewModel.selectedPlace = location
                                        }
                                }
                            }
                        }
                        .mapStyle(viewModel.selectedMode == "Standard" ? .standard : .hybrid)
                        .onTapGesture { position in
                            if let coordinate = proxy.convert(position, from: .local) {
                                viewModel.addLocation(at: coordinate)
                            }
                        }
                        .sheet(item: $viewModel.selectedPlace) { place in
                            EditView(location: place) {
                                viewModel.update(location: $0)
                            }
                        }
                    }
                    
                    Picker("Select Mode", selection: $viewModel.selectedMode) {
                        ForEach(viewModel.modes, id: \.self) {
                            Text($0)
                        }
                    }
                    .padding()
                    .pickerStyle(.segmented)
                }
            } else {
                Button("Unlock Places", action: viewModel.authenticate)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
            }
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showingAlert) {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview {
    ContentView()
}
