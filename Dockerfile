FROM mono:4.8.0.495
ADD ./ /app
WORKDIR /app
RUN [ "./build.sh" ]
