FROM ubuntu/squid:latest

COPY squid.conf /etc/squid/squid.conf

CMD ["squid", "-NYC"]
