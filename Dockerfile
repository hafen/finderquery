FROM r-base:4.0.2

ENV REACT_APP_API_BASE=http://127.0.0.1:8000/api

# Install system dependencies and pre-compiled R packages
RUN apt-get update \
    && apt-get install -y curl git gnupg2 systemctl libgit2-dev libsodium-dev libcurl4-openssl-dev libxml2-dev nginx \
    && apt-get install -y r-cran-rcpp r-cran-fs r-cran-glue r-cran-xfun r-cran-git2r r-cran-yaml r-cran-fansi r-cran-digest r-cran-commonmark r-cran-stringi r-cran-mime r-cran-rlang r-cran-curl r-cran-jsonlite r-cran-askpass r-cran-markdown r-cran-later r-cran-purrr r-cran-processx r-cran-vctrs r-cran-ellipsis r-cran-htmltools r-cran-openssl r-cran-promises r-cran-httpuv r-cran-tibble r-cran-testthat

# Install R packages that aren't pre-compiled
RUN install2.r plumber

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update -y && apt install -y yarn

# Copy files
COPY api /home/docker/api
COPY app /home/docker/app

# Set up and run web server
COPY docker/nginx.conf /etc/nginx/sites-enabled/default
RUN systemctl enable nginx

# Build web app
WORKDIR /home/docker/app
RUN yarn install
RUN yarn build
RUN cp -r build/* /var/www/html/

# Set up and run plumber API service
COPY docker/plumber-api.service /etc/systemd/system/plumber-api.service
RUN systemctl enable plumber-api
# /var/log/journal/plumber-api.service.log

WORKDIR /

RUN systemctl start nginx
RUN systemctl start plumber-api

# docker run -ti r-base:4.0.2 bash
# docker exec -ti fq bash
# docker build . -t finderquery
# # run the container, mapping port 8000 on the container to port 8000 locally
# docker run --rm -td -p 8000:8000 --name=fq finderquery

# # start nginx and plumber-api services
# docker exec fq systemctl start nginx
# docker exec fq systemctl start plumber-api
