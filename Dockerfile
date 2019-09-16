FROM ruby:2.6.0-alpine
WORKDIR /tmp

# ImageMagick以外の依存関係のあるパッケージのinstall
# gccやgitなど、ビルドに必要なものもすべて含まれている
RUN apk --update --no-cache add libxml2-dev libxslt-dev libstdc++ tzdata ca-certificates bash nodejs yarn \
    shadow sudo busybox-suid tzdata alpine-sdk libxml2-dev curl-dev postgresql-dev file file-dev build-base linux-headers

# ImageMagickのインストール、RMagickがまだ7.xに非対応なので6.xをインストール
#RUN apk add --update --no-cache curl && \
#    curl -O "http://dl-4.alpinelinux.org/alpine/edge/community/x86_64/imagemagick6-{6.9.10.60-r0,c%2B%2B-6.9.10.60-r0,dev-6.9.10.60-r0,doc-6.9.10.60-r0,libs-6.9.10.60-r0}.apk" && \
#    apk add --no-cache \
#    imagemagick6-c%2B%2B-6.9.10.60-r0.apk \
#    imagemagick6-dev-6.9.10.60-r0.apk \
#    imagemagick6-libs-6.9.10.60-r0.apk \
#    imagemagick6-6.9.10.60-r0.apk \
#    ruby-rmagick

WORKDIR /usr/src/app

ADD Gemfile Gemfile.lock ./
RUN gem install bundler --no-document && \
    bundle install
