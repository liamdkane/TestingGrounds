import UIKit

struct Constants {
    
    // MARK: Api Constants
    struct Api {
        static let apiKey = "OeedTKxJkMqxojEGs1iMtwxFXdVPXWoP"
        static let giphyBaseUrl = "https://api.giphy.com/v1/gifs/"
    }
    
    struct Reactive {
        static let debounce = 0.3
    }
    
    // MARK: UI Constants
    struct Ui {
        //UI Sizes
        static let cellMargin: CGFloat = 16.0
        static let searchBarHeight = 64
        
        //Image
        static let placeholderImage = UIImage(named: "placeholder")!
        
        //Default Text
        static let errorTitle = "Error"
        static let errorMessage = "Something went wrong!"
        static let actionTitle = "Okay"
        static let promptText = "Search for your favourite gifs."
    }
}
