# --- RUNTIME ---
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# --- BUILD (with Node.js installed) ---
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
# Install Node 20.x (for npm)
RUN apt-get update && apt-get install -y curl ca-certificates gnupg \
 && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y nodejs \
 && node -v && npm -v \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src
# If your build context is repo root, include 'software/' in paths; if context is software/, omit it.
COPY ["sample/sample.csproj", "sample/"]

RUN dotnet restore "sample/sample.csproj"
COPY . .
WORKDIR /src/sample
RUN dotnet build "sample.csproj" -c Release -o /app/build

# --- PUBLISH ---
FROM build AS publish
WORKDIR /src/sample
RUN dotnet publish "sample.csproj" -c Release -o /app/publish

# --- FINAL ---
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "sample.dll"]