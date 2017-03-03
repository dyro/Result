enum Result<T, U> {
    case ok(T)
    case error(U)
}

extension Result {
    /// ```
    /// let isOkay = Result<Int, Error>.ok(10).isOk()
    /// // => true
    ///
    /// let isOkay = Result<Int, String>.error("err").isOk() // => false
    /// // => false
    /// ```
    ///
    /// - returns: `true` if the result is `ok`
    func isOk() -> Bool {
        switch self {
        case .ok: return true
        case .error: return false
        }
    }

    /// ```
    /// let isError = Result<Int, Error>.ok(10).isError()
    /// // => false
    ///
    /// let isError = Result<Int, String>.error("err").isError()
    /// // => true
    /// ```
    ///
    /// - returns: `true` if the result is `error`
    func isError() -> Bool {
        return !self.isOk()
    }
}

extension Result {
    /// the value of `.ok` if value present, otherwise it
    /// will be `nil`
    ///
    /// ```
    /// let result = Result<Int, String>.ok(10)
    /// let value = result.ok
    /// //=> value is 10
    ///
    /// let result = Result<Int, String>.error("ERR")
    /// let value = result.ok
    /// => value is `nil`
    /// ```
    var ok: T? {
        switch self {
        case .ok(let t): return t
        case .error: return nil
        }
    }

    /// the value of `.error` if value present, otherwise it
    /// will be `nil`
    ///
    /// ```
    /// let result = Result<Int, String>.ok(10)
    /// let value = result.error
    /// // => value is nil
    ///
    /// let result = Result<Int, String>.error("ERR")
    /// let value = result.error
    /// // => value is `"ERR"`
    /// ```
    var error: U? {
        switch self {
        case .ok: return nil
        case .error(let e): return e
        }
  }
}

extension Result {
    /// Applies `cb` to the `.ok` value of the `Result` if the result
    /// is `.ok`, otherwise returns the value in `.error`
    ///
    /// ```
    /// let value = Result<Int, String>.ok(0).map { $0 + 10 }
    /// // => .ok(10)
    ///
    /// let value = Result<Int, String>.error("ERROR").map { $0 + 10 }
    /// // => .error("ERROR")
    /// ```
    ///
    /// - parameter cb: func that will be applied to `.ok` if the `result` is
    ///   `.ok`
    ///
    /// - returns: the result after applying `cb` to the value of `.ok` if result was
    ///   `.ok`, otherwise `Result.error(...)` is returned
    func map<V>(cb: (T) -> V) -> Result<V, U> {
        switch self {
        case .ok(let t): return .ok(cb(t))
        case .error(let e): return .error(e)
        }
    }
    /// Applies `cb` to the `.error` value of the `Result` if the result
    /// is `.error`, otherwise returns the value in `.value`
    ///
    /// ```
    /// let value = Result<Int, String>.error("ERROR").map { $0 += ", Oops" }
    /// // => .error("ERROR, Oops")
    ///
    /// let value = Result<Int, String>.value(1).map { $0 += ", Oops" }
    /// // => .ok(1)
    /// ```
    ///
    /// - parameter cb: func that will be applied to `.error` if the `result` is
    ///   `.error`
    ///
    /// - returns: the result after applying `cb` to the value of `.error` if result was
    ///   `.error`, otherwise `Result.ok(...)` is returned
    func mapError<V>(cb: (U) -> V) -> Result<T, V> {
        switch self {
        case .ok(let t): return .ok(t)
        case .error(let e): return .error(cb(e))
        }
    }
}

extension Result {
    /// ```
    /// let a = Result<Int, String>.ok(10)
    /// let b = Result<Int, String>.ok(32)
    ///
    /// if a.and(b).isOk() {
    ///   a.unwrapped() + b.unwrapped() // => 42
    /// }
    /// ```
    /// - parameter result: Result that will be returned if `self` and `result`
    ///   are both `Result.ok`
    ///
    /// - returns: `result` if the result is `Result.ok`, otherwise returns the `.error`
    ///   from `result`
    func and<V>(_ result: Result<V, U>) -> Result<V, U> {
        switch self {
        case .ok: return result
        case .error(let e): return .error(e)
        }
    }

    /// ```
    /// let a = Result<Int, String>.ok(10)
    /// let b = Result<Int, String>.error("ERROR")
    ///
    /// let or = a.or(b).isOk() // => true
    /// ```
    /// - parameter result: Result that will be compared with `self`
    ///
    /// - returns: `self.ok` if `self` is `Result.ok`, otherwise `result` is returned
    ///   which could be `Result.ok` or `Result.error`
    func or(_ result: Result) -> Result<T, U> {
        switch self {
        case .ok(let t): return .ok(t)
        case .error: return result
        }
    }
}

extension Result {
    /// ```
    /// let a = Result<Int, String>.ok(10)
    /// let b = Result<Int, String>.ok(42)
    /// let c = Result<Int< String>.ok(52)
    ///
    /// a.andThen({ $0 * 10 }).
    /// ```
    func addThen<V>(cb: (T) -> Result<V, U>) -> Result<V, U> {
        switch self {
        case .ok(let t): return cb(t)
        case .error(let e): return .error(e)
        }
    }

    func orElse<V>(cb: (U) -> Result<T, V>) -> Result<T, V> {
        switch self {
        case .ok(let t): return .ok(t)
        case .error(let e): return cb(e)
        }
    }
}

extension Result {
    /// ```
    /// let result = Result<Int, String>.ok(10)
    /// let value = result.unwrapped()
    /// // => value is `10`
    ///
    /// let result = Result<Int, String>.error("ERROR")
    /// let value = result.unwrapped()
    /// // => `fatalError` is thrown
    /// ```
    ///
    /// - returns: the value in `.ok` if it's defined. If no value is present,
    ///   `fatalError` will be thrown
    ///
    /// - important: this will crash your program if the instance Result is an `error`.
    func unwrapped() -> T {
        switch self {
        case .ok(let t): return t
        case .error(let e):
            fatalError("called `Result.error(...).unwrapped` on the .error value \(e)")
        }
    }

    /// ```
    /// let result = Result<Int, String>.ok(10)
    /// let value = result.unwrapped(errorMessage: "yikes")
    /// // => value is `10`
    ///
    /// let result = Result<Int, String>.error("ERROR")
    /// let value = result.unwrapped(errorMessage: "yikes")
    /// // => `fatalError` is thrown
    ///```
    ///
    /// - parameter message: message that will be displayed if the value unwrapped is
    ///   an `.error`
    ///
    /// - returns: the value in `.ok` if it's defined. If no value is present,
    ///   `fatalError` will be thrown with the message provided
    ///
    /// - important: this will crash your program if the instance Result is an `error`.
    func unwrapped(errorMessage: String) -> T {
        switch self {
        case .ok(let t): return t
        case .error:
            fatalError(errorMessage)
        }
    }

    ///```
    /// let result = Result<Int, String>.ok(10)
    /// let value = result.unwrapped(or: 1000)
    /// // => value is `10`
    ///
    /// let result = Result<Int, String>.error("ERROR")
    /// let default = 42
    /// let value = result.unwrapped(or: default)
    /// // => value is `42`
    /// ```
    /// - parameter value: value to be returned if the result is a `Result.error`
    ///
    /// - returns: the value of `.ok` if present. If the result is a `Result.error`, 
    ///   the arg passed in to the function will be returned
    func unwrapped(or value: T) -> T {
        switch self {
        case .ok(let t): return t
        case .error: return value
        }
    }
}
