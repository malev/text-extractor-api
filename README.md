# TextExtractor

## API

`POST /v1/convert`

### Mandatory params: 
* files: []
* callbackurl: string

### Optional params:
* encoding: string

### Test

`curl localhost:4567/v1/convert --form file=@data/veredicto.pdf --form callback=http://localhost:3000/callback --form encoding=utf-8`
