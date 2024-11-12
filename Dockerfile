FROM node:alpine

COPY ./api .

RUN npm install

CMD ["npm", "run", "start"]