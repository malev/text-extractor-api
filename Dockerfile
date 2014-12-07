FROM ruby:2.1.2-onbuild

MAINTAINER Marcos Vanetta "marcosvanetta@gmail.com"

RUN apt-get update
RUN apt-get -y install graphicsmagick poppler-utils poppler-data ghostscript pdftk libreoffice

ADD . /app/

WORKDIR /app

RUN bundle install

EXPOSE 4567
CMD ["ruby", "bin/webserver"]
