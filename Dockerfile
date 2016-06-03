#Begin with debian
FROM ioft/armhf-debian:latest
MAINTAINER asyed5@gsu.edu

#RUN 'curl -sLS https://apt.adafruit.com/add | sudo bash'

#RUN apt-get update && apt-get install -y \
#      nginx \
#      node \
#      npm

#RUN apt-get clean


EXPOSE 80
CMD ["/bin/bash", "top"]
