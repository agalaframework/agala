# Agala [![Hex.pm](https://img.shields.io/hexpm/v/agala.svg)](https://hex.pm/packages/agala) [![Travis](https://travis-ci.org/agalaframework/agala.svg?branch=develop)](https://travis-ci.org/agalaframework/agala) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/Virviil/agala.svg?branch=develop)](https://beta.hexfaktor.org/github/Virviil/agala) [![Docs Status](http://inch-ci.org/github/virviil/agala.svg)](http://inch-ci.org/github/virviil/agala) [![Coverage Status](https://coveralls.io/repos/github/agalaframework/agala/badge.svg?branch=develop)](https://coveralls.io/github/agalaframework/agala?branch=develop)

Full-featured messaging bot framework.

## [Documentation](https://hexdocs.pm/agala/)

All nessesary information, including tutorials, examples, guides and API documentation can be found here.

## Installation via Hex

The package is [available in Hex](https://hex.pm/packages/agala), and can be installed as:

  1. Add `agala` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:agala, "~> 2.0.0"}]
  end
  ```

  2. Ensure `agala` is started before your application:

  ```elixir
  def application do
    [applications: [:agala]]
  end
  ```

## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
