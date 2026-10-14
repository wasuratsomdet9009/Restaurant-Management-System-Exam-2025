FROM node:22-slim AS build
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends openssl && rm -rf /var/lib/apt/lists/*
COPY package*.json ./
COPY prisma ./prisma
RUN npm ci && npx prisma generate
COPY tsconfig.json ./
COPY src ./src
RUN npm run build
# Compile the seed so the runtime does not need to download tsx.
RUN npx tsc prisma/seed.ts --outDir seed-dist --target ES2022 --module CommonJS --esModuleInterop --skipLibCheck

FROM node:22-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends openssl && rm -rf /var/lib/apt/lists/*
ENV NODE_ENV=production
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./
COPY --from=build /app/prisma ./prisma
COPY --from=build /app/dist ./dist
COPY --from=build /app/seed-dist ./seed-dist
EXPOSE 3001
CMD ["sh", "-c", "./node_modules/.bin/prisma db push && node seed-dist/seed.js && node dist/app.js"]
