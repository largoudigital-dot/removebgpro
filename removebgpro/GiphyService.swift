import Foundation

struct GiphyResponse: Codable {
    let data: [GiphySticker]
}

struct GiphySticker: Codable, Identifiable {
    let id: String
    let images: GiphyImages
}

struct GiphyImages: Codable {
    let fixedHeight: GiphyImageInfo
    let original: GiphyImageInfo
    
    enum CodingKeys: String, CodingKey {
        case fixedHeight = "fixed_height"
        case original
    }
}

struct GiphyImageInfo: Codable {
    let url: String
    let width: String
    let height: String
}

class GiphyService {
    static let shared = GiphyService()
    private let apiKey = "PXQMoa4Bj9WIzQaFhIlvyZ4gJO9ljKIl"
    private let baseUrl = "https://api.giphy.com/v1/stickers"
    
    func searchStickers(query: String) async throws -> [GiphySticker] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseUrl)/search?api_key=\(apiKey)&q=\(encodedQuery)&limit=20&rating=g") else {
            return []
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("Giphy API Error (Status \(httpResponse.statusCode)): \(errorBody)")
            throw NSError(domain: "GiphyService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Giphy API Error \(httpResponse.statusCode)"])
        }
        
        let responseObj = try JSONDecoder().decode(GiphyResponse.self, from: data)
        return responseObj.data
    }
    
    func getTrendingStickers() async throws -> [GiphySticker] {
        guard let url = URL(string: "\(baseUrl)/trending?api_key=\(apiKey)&limit=20&rating=g") else {
            return []
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("Giphy API Error (Status \(httpResponse.statusCode)): \(errorBody)")
            throw NSError(domain: "GiphyService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Giphy API Error \(httpResponse.statusCode)"])
        }
        
        let responseObj = try JSONDecoder().decode(GiphyResponse.self, from: data)
        return responseObj.data
    }
}
