//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public final class ImageDataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard isOK(response), !data.isEmpty else {
            throw Error.invalidData
        }

        return data
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
