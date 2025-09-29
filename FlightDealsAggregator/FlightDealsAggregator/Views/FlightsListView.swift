//
//  FlightsListView.swift
//  FlightDealsAggregator
//

import SwiftUI

struct FlightsListView: View {
    @State private var viewModel = FlightsViewModel()

    @State private var originText: String = "MOW"
    @State private var destinationText: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showCamera: Bool = false
    @State private var capturedImage: UIImage? = nil
    @State private var saveAlert: Bool = false
    @State private var saveMessage: String = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
        }
        .task {
            viewModel?.date = selectedDate
            await viewModel?.load()
        }
        .onChange(of: originText) { _, newValue in
            viewModel?.origin = newValue.uppercased()
        }
        .onChange(of: destinationText) { _, newValue in
            viewModel?.destination = newValue.isEmpty ? nil : newValue.uppercased()
        }
        .navigationTitle("Deals")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCamera = true
                } label: {
                    Image(systemName: "camera.viewfinder")
                }
            }
        }
        .sheet(isPresented: $showCamera, onDismiss: handleCaptured) {
            CameraView(image: $capturedImage)
        }
        .alert("Saved", isPresented: $saveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveMessage)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField("From", text: $originText)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(.roundedBorder)
                    .frame(minWidth: 80)

                TextField("To (optional)", text: $destinationText)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(.roundedBorder)

                Button(action: {
                    Task { await viewModel?.load() }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel == nil)
            }

            HStack(spacing: 12) {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .onChange(of: selectedDate) { _, newDate in
                        viewModel?.date = newDate
                        Task { await viewModel?.load() }
                    }
            }
        }
        .padding()
    }

    @ViewBuilder
    private var content: some View {
        if viewModel == nil {
            VStack(spacing: 12) {
                Text("API client not configured")
                Text("Add token or keep the provided dev token.")
                    .foregroundStyle(.secondary)
            }
            .padding()
        } else if let vm = viewModel {
            Group {
                if vm.isLoading {
                    List(skeletonFlights, id: \.self) { _ in
                        FlightRow.skeleton
                    }
                    .listStyle(.plain)
                    .redacted(reason: .placeholder)
                    .transition(.opacity)
                } else if let error = vm.errorMessage {
                    ScrollView { Text(error).foregroundStyle(.red).padding() }
                        .transition(.opacity)
                } else if vm.flights.isEmpty {
                    ContentUnavailableView(
                        "No deals",
                        systemImage: "airplane",
                        description: Text("Try changing filters").foregroundStyle(.secondary)
                    )
                    .padding()
                    .transition(.opacity)
                } else {
                    List(vm.flights) { flight in
                        NavigationLink(value: flight) {
                            FlightRow(flight: flight)
                                .contentTransition(.opacity)
                        }
                    }
                    .listStyle(.plain)
                    .animation(.snappy, value: vm.flights)
                    .transition(.opacity)
                }
            }
        }
    }

    private var skeletonFlights: [Int] { Array(0..<8) }

    private func handleCaptured() {
        guard let img = capturedImage else { return }
        Task {
            do {
                try await PhotoSaver.saveToPhotos(img)
                saveMessage = "Saved to Photos"
            } catch {
                    saveMessage = "Save failed: \(error.localizedDescription)"
            }
            saveAlert = true
            capturedImage = nil
        }
    }
}

struct FlightsListNavigation: View {
    var body: some View {
        NavigationStack {
            FlightsListView()
                .navigationDestination(for: Flight.self) { flight in
                    FlightDetailsView(flight: flight)
                }
        }
    }
}

#Preview { FlightsListNavigation() }


