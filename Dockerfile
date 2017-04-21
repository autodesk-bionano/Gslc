# FROM mono:4.8.0.495
FROM mono:3.12.1
ADD ./ /app
WORKDIR /app
RUN [ "./build.sh" ]
