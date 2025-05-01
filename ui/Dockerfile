# Stage 1: Build stage
FROM node:lts-alpine AS builder

WORKDIR /app

# Nur package.json & lock zuerst für Cache
COPY package*.json ./

# Install all deps (inkl. dev)
RUN npm install

# Restlichen Code kopieren
COPY . .

# Projekt bauen (z. B. TypeScript-Compiler, Webpack, etc.)
RUN npm run build

# Stage 2: Runtime stage (klein & sicher)
FROM node:lts-alpine AS runtime

ENV NODE_ENV=production
WORKDIR /app

# Nur die für den Runtime-Betrieb nötigen Dateien kopieren
COPY package*.json ./
RUN npm install --production

# Aus dem Builder: dist + alles was benötigt wird zur Laufzeit
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/src ./src

# Passe bei Bedarf auch Config- oder View-Folder an

EXPOSE 80

# Passe den Startpfad an, wenn dist den Entry Point liefert
CMD ["node", "src/server/main.js"]
