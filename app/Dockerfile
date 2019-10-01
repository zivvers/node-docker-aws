FROM node:10.16.3-alpine

WORKDIR /usr/app

COPY . .

WORKDIR /usr/app/server

ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

RUN echo "Building an image for $NODE_ENV"

RUN npm install

# Install Typescript so we can build assets. Using multi-stage builds would prevent
# typescript from getting included in the final image.
RUN npm install -g typescript

# Install nodemon. It is required by `npm run start` but is pruned when build for production
RUN npm install -g nodemon

RUN npm run build

EXPOSE 4000

CMD [ "npm", "start" ]
