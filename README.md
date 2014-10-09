# TextExtractorAPI

## API

Currently there are two options available: `convert-now` for files smaller than 1MB and `convert` for files up to 5Mb.

Send a request to `POST /v1/convert-now` with:

* file: pdf, docx or odt files (Files can't be bigger than 1Mb).

Or send a request to `POST /v1/convert` with:

* file: pdf, docx or odt files (Files can't be bigger than 5Mb).
* callback: url where you expect the results. The response will look like:

```json
{
    "filename": "your_file.pdf",
    "uuid": "unique identifier",
    "content": "The extracted text"
}
```

## Installing your own instance

You can have your own **TextExtractorApi Server**, you only need to clone this repo and make sure you have the dependencies descripted [here](http://documentcloud.github.io/docsplit/) and of course **Ruby 2.1.2**.

    git clone git@github.com:malev/text-extractor-api.git
    cp config/config.yml.sample config/config.yml
    cp config/resque.yml.sample config/resque.yml
    bundle
    bundle exec ruby bin/webserver

And in another terminal, just run:

    bundle exec rake environment resque:work QUEUE=* COUNT=1

You can customize the limits, just check the [config.yml](config/config.yml.sample) file and tweak it. You can also have more workers available. Just update the `COUNT` environmental variable.

And you are ready to send your requests to `localhost:4567`.

### When developing

    bundle exec rake environment resque:work QUEUE=* COUNT=1

    curl localhost:4567/v1/convert-now --form file=@data/veredicto.pdf 

    resque-web -r 0.0.0.0:6379:1

    curl -vX POST http://localhost:3000/callback -d @test/response.json --header "Content-Type: application/json"

    curl localhost:3000/callback --form filename=filename.txt --form uuid=SECRET --form text="hola que tal"

    require 'json';require 'httparty'; HTTParty.post("http://localhost:3000/callback", {:body => {filename: "filename.txt", uuid: "SECRET", text: "hola que tal"}.to_json})
