import XCTest
@testable import Result

class ResultTests: XCTestCase {
    func testIsOk() {
        let result: Result<Int, String> = .ok(10)

        XCTAssert(result.isOk())
        XCTAssertFalse(result.isError())
    }

    func testIsError() {
        let result = Result<Int, String>.error("ERROR")

        XCTAssert(result.isError())
        XCTAssertFalse(result.isOk())
    }

    func testOkReturnsValue() {
        let result: Result<Int, String> = .ok(100)
        XCTAssertEqual(result.ok, Optional.some(100))
    }

    func testOkReturnsNone() {
        let result: Result<Int, String> = .error("ERROR")
        XCTAssertEqual(result.ok, Optional.none)
    }

    func testErrorReturnsValue() {
        let result: Result<Int, String> = .error("ERROR")
        XCTAssertEqual(result.error, Optional.some("ERROR"))
    }

    func testErrorReturnsNone() {
        let result: Result<Int, String> = .ok(100)
        XCTAssertEqual(result.error, Optional.none)
    }

    func testMapWithOk() {
        let result: Result<Int, String> = .ok(100)
        let test = result.map { $0 + 1 }
        XCTAssertEqual(test.ok, Optional.some(101))
    }

    func testMapWithError() {
        let result: Result<Int, String> = .error("ERROR")
        let test = result.map { $0 + 1 }
        XCTAssertEqual(test.ok, Optional.none)
    }

    func testMapErrorWithOk() {
        let result: Result<Int, String> = .ok(10)
        let test = result.mapError { $0.capitalized }
        XCTAssertEqual(test.error, Optional.none)
    }

    func testMapErrorWithError() {
        let result: Result<Int, String> = .error("error")
        let test = result.mapError { $0.capitalized }
        XCTAssertEqual(test.error, Optional.some("Error"))
    }

    func testAndAllOk() {
        let a: Result<Int, String> = .ok(10)
        let b: Result<Int, String> = .ok(20)
        let c: Result<Int, String> = .ok(20)

        let combined = a.and(b).and(c)

        XCTAssertEqual(combined.ok, Optional.some(20))
        XCTAssertEqual(combined.error, Optional.none)
    }

    func testAndWithErrors() {
        let a: Result<Int, String> = .error("ERROR1")
        let b: Result<Int, String> = .ok(20)
        let c: Result<Int, String> = .ok(20)

        let some = a.and(b).and(c)

        XCTAssertEqual(some.ok, Optional.none)
        XCTAssertEqual(some.error, Optional.some("ERROR1"))

        let d: Result<Int, String> = .ok(2)
        let e: Result<Int, String> = .error("ERROR2")
        let f: Result<Int, String> = .ok(20)

        let error = d.and(e).and(f)

        XCTAssertEqual(error.ok, Optional.none)
        XCTAssertEqual(error.error, Optional.some("ERROR2"))

        let g: Result<Int, String> = .ok(10)
        let h: Result<Int, String> = .ok(20)
        let i: Result<Int, String> = .error("ERROR3")

        let anotherError = g.and(h).and(i)

        XCTAssertEqual(anotherError.ok, Optional.none)
        XCTAssertEqual(anotherError.error, Optional.some("ERROR3"))

        let j: Result<Int, String> = .ok(2)
        let k: Result<Int, String> = .error("ERROR2")
        let l: Result<Int, String> = .error("ERROR3")

        let multipleErrors = j.and(k).and(l)

        XCTAssertEqual(multipleErrors.ok, Optional.none)
        XCTAssertEqual(multipleErrors.error, Optional.some("ERROR2"))
    }

    func testOr() {
        let a: Result<Int, String> = .ok(10)
        let b: Result<Int, String> = .ok(20)
        let or = a.or(b)

        XCTAssertEqual(or.ok, Optional.some(10))
    }

    func testOrWithErrors() {
        let a: Result<Int, String> = .ok(10)
        let b: Result<Int, String> = .error("ERROR")
        let or = a.or(b)

        XCTAssertEqual(or.ok, Optional.some(10))

        let c: Result<Int, String> = .error("ERROR")
        let d: Result<Int, String> = .ok(20)
        let orWithErrors = c.or(d)

        XCTAssertEqual(orWithErrors.ok, Optional.some(20))
    }

    static var allTests : [(String, (ResultTests) -> () throws -> Void)] {
        return [
            ("testIsOk", testIsOk),
            ("testIsError", testIsError),
            ("testOkReturnsValue", testOkReturnsValue),
            ("testOkReturnsNone", testOkReturnsNone),
            ("testErrorReturnsValue", testErrorReturnsValue),
            ("testErrorReturnsNone", testErrorReturnsNone),
            ("testMapWithOk", testMapWithOk),
            ("testMapWithError", testMapWithError),
            ("testMapErrorWithOk", testMapErrorWithOk),
            ("testMapErrorWithError", testMapErrorWithError),
            ("testAnd", testAndAllOk),
            ("testAndWithErros", testAndWithErrors)
        ]
    }
}
