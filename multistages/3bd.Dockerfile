FROM golang:1.16-alpine as web
WORKDIR /app
COPY ./repos/wordsmith .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build ./web/dispatcher.go 

FROM postgres:15.2 as bd
COPY --from=web /app/db/words.sql docker-entrypoint-initdb.d/
ENV POSTGRES_HOST_AUTH_METHOD=trust

FROM ubuntu as words
WORKDIR /
COPY --from=web /app .
COPY --from=web /app/dispatcher web/dispatcher
RUN apt-get update && apt-get install maven openjdk-8-jdk -y && cd words && mvn verify -X
EXPOSE 80
ENTRYPOINT ["./web/dispatcher"]
CMD ["java","-Xmx8m","-Xms8m -jar","words/target/words.jar"]

