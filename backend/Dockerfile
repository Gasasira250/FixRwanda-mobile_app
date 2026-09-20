FROM node:22-alpine
WORKDIR /app
COPY backend/package.json ./
RUN npm install --omit=dev
COPY backend/src ./src
COPY backend/sql ./sql
COPY admin ./admin
ENV NODE_ENV=production
EXPOSE 4000
CMD ["node", "src/index.js"]
