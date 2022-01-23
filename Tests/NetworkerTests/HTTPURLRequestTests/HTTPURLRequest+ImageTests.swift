#if !os(macOS)
import XCTest
@testable import Networker

// MARK: - Image DataTask

extension HTTPURLRequestTests {
    typealias ImageResult = (calledCompletion: Bool, image: ImageResponse?, error: Error?)

    func runImageDataTask(data: Data?, _ response: HTTPURLResponse? = nil, _ error: Error? = nil) -> ImageResult {
        var calledCompletion = false
        var receivedImage: ImageResponse?
        var receivedError: Error?

        self.sut.imageDataTask() { result in
            calledCompletion = true

            receivedImage = result.success
            receivedError = result.failure
        }

        self.session.lastTask?.completionHandler(data, response, error)

        return (calledCompletion, receivedImage, receivedError)
    }
    
    func test_imageDataTask_givenInvalidData_callsFailure() {
        let result = self.runImageDataTask(data: Data(), self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.image)
        XCTAssertNotNil(result.error)
    }
    
    func test_imageDataTask_validData_callsSuccess() throws {
        let image = UIImage.create(with: .black, size: CGSize(width: 10, height: 10))
        let imageData = image!.pngData()
        let result = self.runImageDataTask(data: imageData, self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNotNil(result.image)
        XCTAssertNil(result.error)
    }
    
    @available(iOS 10.0, *)
    func test_imageDataTask_callsInCorrectDispatchQueue() {
        let image = UIImage.create(with: .black, size: CGSize(width: 10, height: 10))
        let imageData = image!.pngData()
        let targetQueue = DispatchQueue(label: #function)

        let expectation = self.expectation(description: #function)
        self.sut.imageDataTask(dispatchQueue: targetQueue) { result in
            dispatchPrecondition(condition: .onQueue(targetQueue))
            expectation.fulfill()
        }

        self.session.lastTask?.completionHandler(imageData, self.response(200), nil)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
}
#endif
