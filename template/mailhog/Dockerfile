# latest mailhog image
FROM golang:1.4

RUN go get github.com/mailhog/MailHog

EXPOSE 1025 8025

ENTRYPOINT ["/go/bin/MailHog"]

# apt-get what we need
RUN apt update && apt install -y \
  telnet \
  vim \
  nano \
  net-tools \
  wget

# root .bashrc
RUN echo "PS1='\[\e[31m\]\u\[\e[m\]@\h:\w\$ '" >> /root/.bashrc
RUN echo "alias ll='ls -la'" >> /root/.bashrc
RUN echo "export TERM=xterm" >> /root/.bashrc