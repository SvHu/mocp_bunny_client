##  Requirements
    - Ruby (2.1.x) and `bundler` gem

## Installation

```sh
$ git clone git@github.com:SvHu/mocp_bunny_client.git
$ cd mocp_bunny_client
$ bundle install --path .bundle
```

## Usage
To see all script commands just run:
```sh
$ ./bin/play
```
Added support for play to be symlinked into $PATH. Now Bundler finds its files, regardless how the script was called and what the current directory was.

Example:

ln -s /path/to/mocp_bunny_client/bin/play /usr/local/bin

```sh
play what
```

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/SvHu/mocp_bunny_client/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

