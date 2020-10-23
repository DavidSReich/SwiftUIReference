
# SwiftUIReference

**SwiftUIReference** is a modernized **GiphyTags** using SwiftUI and Swift 5.

It is written in Swift 5 and Xcode Version 12.0.1 (12A7300)

## Overview  
This app queries the GIPHY website via its URL API interface, and uses the tags returned to search deeper and deeper.  
(This isn't necessarily a good thing!)  
To use the app you need to get an API key from <https://developers.giphy.com/dashboard/?create=true>.  
The app can open the Giphy website to make it easier for the user to get the key.

## SwiftUI  
### The main full screen view uses:  
* A view model (MVVM)  
* `ProgressView` for the loading activity indicator  
* Sheet views - for settings and tags selection  
* `Alert` views  
* `ToolbarItem`s that vary with changes in the view model  
* A `NavigationLink` to a detail view  
* Master-detail user interface design

### Additional large views  
* A SwiftUI launch screen view  
* A detail view  
* A settings view - displayed as a `sheet`  
* A multiple selection view - displayed as a `sheet`  

### UIKit wrapper  
* `UIViewRepresentable` wrapper around `UIImageView`  

## `Combine`, etc.  
* `MainViewModel` is an `ObservableObject` instantiated as an `@StateObject`.
* Settings view uses `@AppStorage`.  
* Most data handling and networking uses `AnyPublisher` for asynchronous calls.
* `Result` is also used for non-asynch to avoid excessive nesting.

## Extensions  
* Generic `Data` extensions for both `Result<>` and `AnyPublisher<>`  
 * `func decodeData<T: Decodable>() -> Result<T, ReferenceError>`  
 * `func decodeData<T: Decodable>() -> AnyPublisher<T, ReferenceError>`  

* `HTTPURLResponse` extension  
 * `HTTPURLResponse.validateData(Data, URLResponse, ...) -> AnyPublisher<Data, ReferenceError>`  

## Networking  
Networking uses `URLSession.dataTaskPublisher` and uses `AnyPublisher<>` for most networking objects.  

* `NetworkService.getDataPublisher() -> AnyPublisher<Data, ReferenceError>`  
 * using `URLSession.dataTaskPublisher`  

## Unit tests
Except for SwiftUI views almost all code is covered by unit tests.

## UI tests
The `SettingsView` has UI tests.  It is the only `View` with a significant number of controls that can be readily tested.
