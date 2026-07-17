import Foundation

final class RetryNetworkClient: NetworkClientProtocol {
    
    private let delegate: NetworkClientProtocol
    private let maxRetries: Int
    private let baseDelay: TimeInterval
    private let retryableStatusCodes: Set<Int>
    
    init(
        delegate: NetworkClientProtocol,
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        retryableStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504]
    ) {
        self.delegate = delegate
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.retryableStatusCodes = retryableStatusCodes
    }
    
    func send<T: Decodable>(_ request: APIRequest) async throws -> T {
        var lastError: Error?
        
        for attempt in 0...maxRetries {
            do {
                return try await delegate.send(request)
            } catch {
                lastError = error
                
                guard attempt < maxRetries, shouldRetry(error: error) else {
                    throw error
                }
                
                try await waitForNextAttempt(attempt: attempt)
            }
        }
        
        throw lastError ?? URLError(.unknown)
    }
    
    func sendVoid(_ request: APIRequest) async throws {
        var lastError: Error?
        
        for attempt in 0...maxRetries {
            do {
                try await delegate.sendVoid(request)
                return
            } catch {
                lastError = error
                
                guard attempt < maxRetries, shouldRetry(error: error) else {
                    throw error
                }
                
                try await waitForNextAttempt(attempt: attempt)
            }
        }
        
        throw lastError ?? URLError(.unknown)
    }
    
    // MARK: - Private
    
    private func shouldRetry(error: Error) -> Bool {
        if let apiError = error as? APIError {
            switch apiError {
            case .httpError(let code, _):
                return retryableStatusCodes.contains(code)
            case .cancelled, .unauthorized:
                return false
            default:
                return true
            }
        }
        
        let nsError = error as NSError
        let codes: [Int] = [
            NSURLErrorTimedOut,
            NSURLErrorCannotFindHost,
            NSURLErrorCannotConnectToHost,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorNotConnectedToInternet
        ]
        return codes.contains(nsError.code)
    }
    
    private func waitForNextAttempt(attempt: Int) async throws {
        let delay = baseDelay * pow(2.0, TimeInterval(attempt))
        let jitter = Double.random(in: 0...0.5)
        try await Task.sleep(nanoseconds: UInt64((delay + jitter) * 1_000_000_000))
    }
}
