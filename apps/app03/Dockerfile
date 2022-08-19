FROM node:current-alpine as build
WORKDIR /app
COPY package.json .
COPY yarn.lock .
RUN yarn install --production
COPY VERSION .

FROM build as development
RUN yarn install
COPY src ./src
CMD ["yarn", "run", "dev"]

FROM build as production
COPY src ./src
CMD ["yarn", "run", "start"]