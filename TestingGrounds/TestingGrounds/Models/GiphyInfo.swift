import Foundation

struct GiphyInfoContainer: Decodable {
    let data: [GiphyInfo]
    let pagination: GiphyPageData
}

struct GiphyPageData: Decodable {
    let offset: Int
    let total_count: Int
}

struct GiphyInfo: Decodable {
    let images: ImagesData
}

struct ImagesData: Decodable {
    let fixed_width: ImageData
}

struct ImageData: Decodable {
    let url: URL
}
