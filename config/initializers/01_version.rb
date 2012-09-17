module Review
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 13
    TINY = 7
    BUILD = nil # nil, "pre", "beta1", "beta2", "rc", "rc2"

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')
  end
end
