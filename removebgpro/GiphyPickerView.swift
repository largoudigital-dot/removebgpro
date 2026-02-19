import SwiftUI

struct GiphyPickerView: View {
    let onSelected: (String) -> Void
    @State private var searchText = ""
    @State private var stickers: [GiphySticker] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var searchTask: Task<Void, Never>?
    
    private let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        VStack(spacing: 0) {
            // GIPHY Attribution and Search Bar
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("GIPHY durchsuchen", text: $searchText)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .onChange(of: searchText) { newValue in
                            performSearch(query: newValue)
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                
                HStack {
                    Spacer()
                    Link(destination: URL(string: "https://giphy.com")!) {
                        Text("Powered by GIPHY")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.trailing, 4)
            }
            .padding()
            
            if isLoading && stickers.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Erneut versuchen") {
                        errorMessage = nil
                        loadTrending()
                    }
                    .buttonStyle(.bordered)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(stickers) { sticker in
                            Button(action: {
                                onSelected(sticker.images.original.url)
                            }) {
                                AsyncImage(url: URL(string: sticker.images.fixedHeight.url)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Color.secondary.opacity(0.1)
                                }
                                .frame(height: 100)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            if stickers.isEmpty && errorMessage == nil {
                loadTrending()
            }
        }
    }
    
    private func loadTrending() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let trending = try await GiphyService.shared.getTrendingStickers()
                await MainActor.run {
                    self.stickers = trending
                    self.isLoading = false
                    if trending.isEmpty {
                        self.errorMessage = "Keine Sticker gefunden"
                    }
                }
            } catch {
                print("Error loading trending: \(error)")
                await MainActor.run { 
                    self.isLoading = false
                    self.errorMessage = "Fehler beim Laden von GIPHY. Bitte Internetverbindung prüfen."
                }
            }
        }
    }
    
    private func performSearch(query: String) {
        searchTask?.cancel()
        
        if query.isEmpty {
            loadTrending()
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce
            if Task.isCancelled { return }
            
            await MainActor.run { 
                isLoading = true 
                errorMessage = nil
            }
            
            do {
                let results = try await GiphyService.shared.searchStickers(query: query)
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self.stickers = results
                    self.isLoading = false
                    if results.isEmpty {
                        self.errorMessage = "Keine Sticker für \"\(query)\" gefunden"
                    }
                }
            } catch {
                print("Error searching Giphy: \(error)")
                await MainActor.run { 
                    self.isLoading = false
                    self.errorMessage = "Suche fehlgeschlagen"
                }
            }
        }
    }
}
