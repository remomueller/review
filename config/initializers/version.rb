module Review
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 6
    TINY = 0
    BUILD = "alpha" # nil, "pre", "beta1", "beta2", "rc", "rc2"

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')
  end
end