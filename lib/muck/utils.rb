module Muck
  module Utils

    def red(text)
      "\e[31m#{text}\e[0m"
    end

    def green(text)
      "\e[32m#{text}\e[0m"
    end

    def yellow(text)
      "\e[33m#{text}\e[0m"
    end

    def blue(text)
      "\e[34m#{text}\e[0m"
    end

    def pink(text)
      "\e[35m#{text}\e[0m"
    end

  end
end
