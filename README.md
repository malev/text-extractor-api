# TextExtractor

## API

`POST /v1/convert`

## Running

    bundle exec ruby bin/webserver

### Mandatory params: 
* files: []
* callbackurl: string

### Optional params:
* encoding: string

### Test

    bundle exec rake environment resque:work QUEUE=* COUNT=1

    curl localhost:4567/v1/convert --form file=@data/veredicto.pdf --form callback=http://localhost:3000/callback --form encoding=utf-8

    resque-web -r 0.0.0.0:6379:1
