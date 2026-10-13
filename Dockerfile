# ---- Build stage ---------------------------------------------------------
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Supabase project settings are compiled into the web bundle at build time.
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --no-web-resources-cdn \
      --dart-define=SUPABASE_URL=${SUPABASE_URL} \
      --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}

# ---- Serve stage ---------------------------------------------------------
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
