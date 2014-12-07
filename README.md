# TextExtractorAPI

## API

Send a request to `POST /v1/convert` with:

* file: pdf, docx or odt files (Files can't be bigger than 1Mb).

The response will look like:

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
    bundle
    bundle exec ruby bin/webserver

You can customize the limits, just check the [config.yml](config/config.yml.sample) file and tweak it. You can also have more workers available. Just update the `COUNT` environmental variable.

And you are ready to send your requests to `localhost:4567`.

### When developing

    curl localhost:4567/v1/convert --form file=@data/veredicto.pdf
