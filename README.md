# TestingGrounds
GIPHY API Render


## Tools/Install

1. Xcode 12.2
2. [Alamofire](https://github.com/Alamofire/Alamofire)
3. [Snapkit](https://github.com/SnapKit/SnapKit)
4. [YYImage](https://github.com/ibireme/YYImage)
5. [ReactiveSwift/ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveSwift)

- Install XCode
- [Install Carthage](https://github.com/Carthage/Carthage#installing-carthage)  
- run `carthage.sh bootstrap --platform iOS` re: [XCode 12 Workaround](https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md)

## Cool Features

A couple extra things I added that I think are cool.

- A searchbar which searches as you type.
- Pagination of the API call to enable users to see all the results
- Prefetching of data/gifs for a more seamless scrolling experience


## Code Design Decisions

###### Networking

The networking layer follows a similar pattern I have used in previous projects.

- `Network` wraps `Alamofire` in a Reactive shell and passes back `APIError` or `Data`. Conforming to `Networkable` allows for easy mocking of this structure. 
- `Request` adds a layer of obstraction to `Networkable` while casting the responding `Data` into the appropriate object.
- `GiphyURLRequestConvertible` allows for easily maintainable and extendable requests which already contain the default parameters and baseUrl needed to connect to the GIPHY API.

###### MVVM + ReactiveSwift

At this point an industry standard, I believe the increased testibility and intuitive multithreading are incredible aspects of this design pattern.

###### UI/UX

I went with an absolutely stripped down UI. 

- An empty state which prompts the user to search, a generic error message when networking issues occur, and a system search bar keep this as intuitive as possible. 
- GIFs are displayed in a `UICollectionView` which renders 1 column in portrait and 2 in landscape. 
- User can tap anywhere to dismiss the presented keyboard.
- `YYImage` is initalised with the incoming GIF data and renders the GIFs in a `YYAnimatedImageView`

###### [GIPHY SDK](https://github.com/Giphy/giphy-ios-sdk-ui-example/blob/master/Docs.md)

This is an alternative way to implement this same app, but as this is more of a playground for me to look at patterns and ideas, I feel it undermines the purpose :).

###### Closing

Futher explanations can be found commented in the code, and I'm more than happy to discuss anything else in more detail.
