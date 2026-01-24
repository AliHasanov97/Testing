# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY Testing/Testing.csproj Testing/
RUN dotnet restore "Testing/Testing.csproj"

# Copy everything else and build
COPY Testing/ Testing/
WORKDIR /src/Testing
RUN dotnet build "Testing.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "Testing.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Copy published files
COPY --from=publish /app/publish .

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "Testing.dll"]