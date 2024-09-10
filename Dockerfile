FROM ubuntu/squid:latest

# Install Nginx and Python
RUN apt-get update && apt-get install -y nginx python3

# Copy Squid config
COPY squid.conf /etc/squid/squid.conf

# Create a simple Python server script
RUN echo 'from http.server import HTTPServer, SimpleHTTPRequestHandler\n\
import socket\n\
\n\
class Handler(SimpleHTTPRequestHandler):\n\
    def do_GET(self):\n\
        self.send_response(200)\n\
        self.send_header("Content-type", "text/plain")\n\
        self.end_headers()\n\
        self.wfile.write(f"Server is up. Hostname: {socket.gethostname()}".encode())\n\
\n\
httpd = HTTPServer(("", 8080), Handler)\n\
httpd.serve_forever()' > /root/server.py

# Copy Nginx config
RUN echo 'events { worker_connections 1024; }\n\
http {\n\
    server {\n\
        listen 80;\n\
        location / {\n\
            proxy_pass http://localhost:8080;\n\
        }\n\
    }\n\
}' > /etc/nginx/nginx.conf

# Start Squid, Nginx, and Python server
CMD service nginx start && python3 /root/server.py & squid -NYC
