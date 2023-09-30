FROM node:14.15.5-alpine3.13 AS explorer

WORKDIR /explorer

COPY ./package.json .
COPY ./package-lock.json .

# install frontend dependencies before copying the frontend code
# into the container so we get docker cache benefits
RUN npm install

# running ngcc before build_prod lets us utilize the docker
# cache and significantly speeds up builds without requiring us
# to import/export the node_modules folder from the container
RUN npm run ngcc

COPY ./angular.json .
COPY ./tsconfig.json .
COPY ./tsconfig.app.json .
COPY ./tslint.json .
COPY ./src ./src

RUN npm run build_prod

# build minified version of frontend, served using caddy
FROM caddy:2.6.4-alpine

WORKDIR /explorer

COPY ./Caddyfile .
COPY --from=explorer /explorer/dist .

ENTRYPOINT ["caddy", "run"]
