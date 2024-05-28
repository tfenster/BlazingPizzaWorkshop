FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5141

ENV ASPNETCORE_URLS=http://+:5141

USER app
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Production
WORKDIR /src
COPY ["BlazingPizza/BlazingPizza.csproj", "BlazingPizza/"]
COPY ["BlazingPizza.Client/BlazingPizza.Client.csproj", "BlazingPizza.Client/"]
COPY ["BlazingPizza.Shared/BlazingPizza.Shared.csproj", "BlazingPizza.Shared/"]
COPY ["BlazingPizza.ComponentsLibrary/BlazingPizza.ComponentsLibrary.csproj", "BlazingPizza.ComponentsLibrary/"]
RUN dotnet restore "BlazingPizza/BlazingPizza.csproj"
COPY . .
WORKDIR "/src/BlazingPizza"
RUN dotnet build "BlazingPizza.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Production
RUN dotnet publish "BlazingPizza.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
USER root
ENTRYPOINT ["dotnet", "BlazingPizza.dll"]
