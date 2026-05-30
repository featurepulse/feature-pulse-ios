// swiftlint:disable identifier_name
@testable import FeaturePulse
import Foundation
import Testing

@Suite(.serialized, .tags(.networking))
struct NetworkClientTests {
    init() {
        FeaturePulse.shared.apiKey = "test-api-key"
        FeaturePulse.shared.baseURL = "https://api.example.com"
        MockURLProtocol.requestHandler = nil
    }

    @Test
    func `request throws when API key is missing`() async throws {
        let client = makeClient()

        for apiKey in ["", "   "] {
            FeaturePulse.shared.apiKey = apiKey

            do {
                let _: EmptyResponse = try await client.request(.activity)
                Issue.record("Expected missing API key error")
            } catch {
                #expect(error as? FeaturePulseError == .missingAPIKey)
            }
        }

        resetSharedConfiguration()
    }

    @Test
    func `request sends headers method body and decodes response`() async throws {
        let client = makeClient()
        let requestBody = ActivityRequest(userIdentifier: "device-1", activityType: "app_open")

        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == "https://api.example.com/api/sdk/activity")
            #expect(request.httpMethod == "POST")
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
            #expect(request.value(forHTTPHeaderField: "X-API-Key") == "test-api-key")

            let body = try #require(request.httpBodyData)
            let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
            #expect(json["user_identifier"] as? String == "device-1")
            #expect(json["activity_type"] as? String == "app_open")

            return try (
                HTTPURLResponse(
                    url: #require(request.url),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                #"{"success":true,"message":"ok"}"#.data(using: .utf8)!
            )
        }

        configureSharedForRequest()
        let response: ActivityResponse = try await client.request(.activity, body: requestBody)

        #expect(response.success)
        #expect(response.message == "ok")

        resetSharedConfiguration()
    }

    @Test
    func `request void maps expected HTTP status codes`() async throws {
        let client = makeClient()

        try await assertStatusCode(403, mapsTo: .paymentRequired, client: client)
        try await assertStatusCode(409, mapsTo: .alreadyVoted, client: client)
        try await assertStatusCode(500, mapsTo: .serverError(500), client: client)

        resetSharedConfiguration()
    }

    @Test
    func `request throws decoding error for invalid JSON`() async throws {
        let client = makeClient()

        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data("not json".utf8)
            )
        }

        configureSharedForRequest()
        do {
            let _: ActivityResponse = try await client.request(.activity)
            Issue.record("Expected decoding error")
        } catch {
            #expect(error as? FeaturePulseError == .decodingError)
        }

        resetSharedConfiguration()
    }

    private func assertStatusCode(
        _ statusCode: Int,
        mapsTo expectedError: FeaturePulseError,
        client: NetworkClient
    ) async throws {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data()
            )
        }

        do {
            configureSharedForRequest()
            try await client.requestVoid(.submitFeatureRequest)
            Issue.record("Expected \(expectedError)")
        } catch {
            #expect(error as? FeaturePulseError == expectedError)
        }
    }

    private func makeClient() -> NetworkClient {
        configureSharedForRequest()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return NetworkClient(session: URLSession(configuration: configuration))
    }

    private func configureSharedForRequest() {
        FeaturePulse.shared.apiKey = "test-api-key"
        FeaturePulse.shared.baseURL = "https://api.example.com"
    }

    private func resetSharedConfiguration() {
        MockURLProtocol.requestHandler = nil
        FeaturePulse.shared.apiKey = ""
        FeaturePulse.shared.baseURL = "https://featurepul.se"
    }
}

private final class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private extension URLRequest {
    var httpBodyData: Data? {
        if let httpBody {
            return httpBody
        }

        guard let httpBodyStream else {
            return nil
        }

        httpBodyStream.open()
        defer { httpBodyStream.close() }

        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        while httpBodyStream.hasBytesAvailable {
            let readCount = httpBodyStream.read(buffer, maxLength: bufferSize)
            guard readCount > 0 else {
                break
            }
            data.append(buffer, count: readCount)
        }

        return data
    }
}

// swiftlint:enable identifier_name
