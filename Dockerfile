# Use a lightweight Nginx base image
FROM nginx:alpine

# Copy our static HTML into the Nginx web root
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 (default for Nginx)
EXPOSE 80
