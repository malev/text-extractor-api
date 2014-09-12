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

    curl -vX POST http://localhost:3000/callback -d @test/response.json --header "Content-Type: application/json"

    curl localhost:3000/callback --form filename=filename.txt --form uuid=SECRET --form text="hola que tal"

    require 'json';require 'httparty'; HTTParty.post("http://localhost:3000/callback", {:body => {filename: "filename.txt", uuid: "SECRET", text: "hola que tal"}.to_json})
