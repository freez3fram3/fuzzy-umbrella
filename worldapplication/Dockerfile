FROM nginx:alpine

# Remove default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy your custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/
COPY pages /usr/share/nginx/pages

# Expose port 443
EXPOSE 443

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]