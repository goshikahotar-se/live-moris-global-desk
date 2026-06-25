# syntax=docker/dockerfile:1

# --- Build stage: compile and publish the app ---
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Restore first (uses Docker layer caching: only re-runs if the csproj changes)
COPY MorisGlobalDesk/MorisGlobalDesk.csproj MorisGlobalDesk/
RUN dotnet restore MorisGlobalDesk/MorisGlobalDesk.csproj

# Copy the rest of the source and publish a Release build
COPY . .
RUN dotnet publish MorisGlobalDesk/MorisGlobalDesk.csproj -c Release -o /app/publish /p:UseAppHost=false

# --- Runtime stage: small image that only runs the published output ---
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# tzdata lets Linux resolve the time zones the app requests (Mauritius / UK).
# Without it, TimeZoneInfo.FindSystemTimeZoneById throws at runtime.
RUN apt-get update \
    && apt-get install -y --no-install-recommends tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/publish .

# Run as the non-root user provided by the base image (security best practice).
USER $APP_UID

EXPOSE 8080

# Bind to the port the host provides ($PORT), defaulting to 8080 locally.
# `exec` makes dotnet PID 1 so it receives SIGTERM for graceful shutdown.
ENTRYPOINT ["sh", "-c", "exec dotnet MorisGlobalDesk.dll --urls http://+:${PORT:-8080}"]
