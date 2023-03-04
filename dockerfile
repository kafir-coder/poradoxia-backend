# syntax=docker/dockerfile:1
# ---- Base Node ----
FROM node:lts AS base

# set working directory
WORKDIR /app

# copy project file
COPY package* .
COPY tsconfig.json .

# ---- Dependencies ----
FROM base AS dependencies

WORKDIR /app
# install node packages

COPY src .
RUN npm install --omit=dev
# copy production node_modules aside
RUN cp -R node_modules prod_node_modules
# install ALL node_modules, including 'devDependencies'
RUN npm install
RUN npm run build

# ---- Release ----
FROM node:lts AS release

WORKDIR /app
# copy production node_modules
COPY --from=dependencies /app/prod_node_modules ./node_modules
COPY --from=dependencies /app/package* ./
# copy app sources
COPY --from=dependencies /app/dist ./dist

CMD npm run start:prod
