# HTTPURLRequest

**HTTPURLRequest** is an easy way of an HTTP networking in Swift.

`HTTPURLRequest` keeps the information about the request using [`URLRequest`](https://developer.apple.com/documentation/foundation/urlrequest) and uses [`URLSession`](https://developer.apple.com/documentation/foundation/urlsession) to send the request to a server.

## Content
- [Installation](#Installation)
    - [CocoaPods](#CocoaPods)
    - [Swift Package Manager](#Swift-Package-Manager)
- [Creating Request](#Creating-Request)
    - [`String` path](#Request-with-%60String%60-path)
    - [`URL`](#Request-with-%60URL%60)
    - [`URLRequest`](#Request-with-%60URLRequest%60)
        - [`HTTPHeader`](#%60HTTPHeader%60)
- [Making Requests](#Making-Requests)
    - [`Decodable`](#Making-%60Decodable%60-Requests)
    - [`jsonObject`](#Making-%60jsonObject%60-Requests)
    - [`Image`](#Making-%60Image%60-Requests)
- [Unsuccessful HTTP status code](#Unsuccessful-HTTP-status-code)

## Installation

### CocoaPods
[`CocoaPods`](https://cocoapods.org/) is a dependency manager for Swift and Objective-C Cocoa projects. To integrate `Networker` into your Xcode project using CocoaPods, specify it in your `Podfile`:
```ruby
pod 'Networker', git: 'https://github.com/SwiftExtensions/HTTPURLRequest.git'
```

[Go to content](#Content)

### Swift Package Manager
To add a package dependency to your Xcode project, select File > Swift Packages > Add Package Dependency and enter `Networker` repository URL:
```
https://github.com/SwiftExtensions/HTTPURLRequest.git
```
You can also navigate to your target’s General pane, and in the “Frameworks, Libraries, and Embedded Content” section, click the + button, select Add Other, and choose Add Package Dependency.

For more information, see [`Adding Package Dependencies to Your App`](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

[Go to content](#Content)

## Creating Request
There are available 3 request options: with [`String`](https://developer.apple.com/documentation/swift/string) path, [`URL`](https://developer.apple.com/documentation/foundation/url) and [`URLRequest`](https://developer.apple.com/documentation/foundation/urlrequest).

[Go to content](#Content)

### Request with `String` path
> **Warning**. If the path is empty string or has an invalid value an error is thrown: `HTTPURLRequest.Error.emptyPath` or `HTTPURLRequest.Error.invalidPath(path)` accordingly.
```swift
let request = try? HTTPURLRequest(path: "http://example.com/")
```
For fast debug purposes you can use:
```swift
let result: Result<HTTPURLRequest, Error> = HTTPURLRequest.create(path: "http://example.com/")
print(result)
```

[Go to content](#Content)

### Request with `URL`
```swift
let url = URL(string: "http://example.com/")!
let request = HTTPURLRequest(url: url)
```

[Go to content](#Content)

### Request with `URLRequest`
```swift
let url = URL(string: "http://example.com/")!
let urlRequest = URLRequest(url: url)
let request = HTTPURLRequest(request: urlRequest)
```

[Go to content](#Content)

#### `HTTPHeader`
**HTTPHeader** is a syntactic sugar of using HTTP headers field in URLRequest.
```swift
let url = URL(string: "http://example.com/")!
var urlRequest = URLRequest(url: url)
urlRequest.setHTTPHeader(.contentType)
let request = HTTPURLRequest(request: urlRequest)

extension HTTPHeader {
    static let contentType = HTTPHeader(name: "Content-Type", value: "text/html")
}
```

[Go to content](#Content)

## Making Requests
> **Warning**. Don't forget to pass the response to the main thread if necessary, as requests are executed in the background thread.
```swift
request.dataTask() { response in
    switch response {
    case let .success(result):
        print(result)
    case let .failure(error):
        print(error)
    }
}
```
`response` type is `Result<DataResponse, Error>`.

[`Result`](https://developer.apple.com/documentation/swift/result) is a value that represents either a success or a failure, including an associated value in each case from `Swift Standard Library Framework`.

`DataResponse` is simple [`Struct`](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html).
```swift
struct DataResponse: Equatable {
    let data: Data
    let response: HTTPURLResponse
}
```
If you are only interested in data, you can use the `success` property from `response`:
```swift
request.dataTask() { response in
    print(response.success)
}
```
To get `String` value from `response`:
```swift
let data: Data? = response.success?.data
let string: String? = data?.utf8String
```
To get `UIImage` value from `response` (_pass `response` to the main thread when working with `UI`_):
```swift
request.dataTask(dispatchQueue: .main) { response in
    let data: Data? = response.success?.data
    let image: UIImage? = data?.image
    ...
}
```
To get `Decodable` value from `response`:
> For more information about `Decodable`, see [`Encoding and Decoding Custom Types`](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types).
```swift
struct Product: Decodable {
    let title: String
}
let data: Data? = response.success?.data
let product: Product? = data?.decoding(type: Product.self).success
```
To get `jsonObject` value from `response`:
> For more information about `JSON in Swift`, see [`Working with JSON in Swift`](https://developer.apple.com/swift/blog/?id=37).
```swift
let data: Data? = response.success?.data
let jsonObject: Any? = data?.json().success
```

[Go to content](#Content)

### Making `Decodable` Requests
```swift
struct Product: Decodable {
    let title: String
}
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
request.dataTask(decoding: Product.self, decoder: decoder, dispatchQueue: .main) { response in
    switch response {
    case let .success(result):
        print(result.decoded)
    case let .failure(error):
        print(error)
    }
}
```
`response` type is `Result<DecodableResponse, Error>`.

[`Result`](https://developer.apple.com/documentation/swift/result) is a value that represents either a success or a failure, including an associated value in each case from `Swift Standard Library Framework`.

`DecodableResponse` is simple [`Struct`](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html).
```swift
struct DecodableResponse<T: Decodable> {
    let decoded: T
    let response: HTTPURLResponse
}
```
If you are only interested in data, you can use the `success` property from `response`:
```swift
struct Product: Decodable {
    let title: String
}
request.dataTask(decoding: Product.self) { response in
    let result: DecodableResponse<Product>? = response.success
    let product: Product? = result?.decoded
    print(product)
}
```

[Go to content](#Content)

### Making `jsonObject` Requests
```swift
request.jsonDataTask() { response in
    switch response {
    case let .success(result):
        print(result.json)
    case let .failure(error):
        print(error)
    }
}
```
`response` type is `Result<JSONResponse, Error>`.

[`Result`](https://developer.apple.com/documentation/swift/result) is a value that represents either a success or a failure, including an associated value in each case from `Swift Standard Library Framework`.

`JSONResponse` is simple [`Struct`](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html).
```swift
struct JSONResponse {
    let json: Any
    let response: HTTPURLResponse
}
```
If you are only interested in data, you can use the `success` property from `response`:
```swift
request.jsonDataTask() { response in
    let result: JSONResponse? = response.success
    let json: Any? = result?.json
    print(json)
}
```

[Go to content](#Content)

### Making `Image` Requests
> **Warning**. Don't forget to pass the response to the main thread when working with UI, as requests are executed in the background thread.
```swift
request.imageDataTask() { response in
    switch response {
    case let .success(result):
        DispatchQueue.main.async {
            let image: UIImage = result.image
            ...
        }
    case let .failure(error):
        print(error)
    }
}
```
`response` type is `Result<ImageResponse, Error>`.

[`Result`](https://developer.apple.com/documentation/swift/result) is a value that represents either a success or a failure, including an associated value in each case from `Swift Standard Library Framework`.

`ImageResponse` is simple [`Struct`](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html).
```swift
struct ImageResponse {
    let image: UIImage
    let response: HTTPURLResponse
}
```
If you are only interested in data, you can use the `success` property from `response`:
```swift
request.imageDataTask() { response in
    let result: ImageResponse? = response.success
    DispatchQueue.main.async {
        let image: UIImage? = result?.image
        ...
    }
}
```

[Go to content](#Content)

## Unsuccessful HTTP status code

All HTTP status codes out of range 200...299 calls failure. 
To get the data in case of an unsuccessful status code use the error parameter `unsuccessfulHTTPStatusCodeData`.
```swift
request.dataTask() { response in
    switch response {
    case let .success(result):
        print(result)
    case let .failure(error):
        if let httpData = error.httpURLRequest?.unsuccessfulHTTPStatusCodeData {
            print(httpData.data.utf8String)
        }
    }
}
```

[Go to content](#Content)

