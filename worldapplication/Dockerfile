FROM nginx:alpine

# Remove default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/

# Copy static HTML files
COPY pages /usr/share/nginx/pages

# Expose port 80 instead of 443
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]