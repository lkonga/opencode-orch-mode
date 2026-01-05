# VPS Generic Application Deployment Patterns

<!-- Purpose: Application-specific deployment patterns for common SSGs and frameworks -->
<!-- Related: vps-generic-deployment skill -->

## Overview

This document provides specific deployment patterns for popular static site generators and JavaScript frameworks commonly deployed on VPS environments.

## Static Site Generators

### Hugo Deployment

**Characteristics:**
- Extremely fast builds
- Single binary
- No runtime dependencies
- Native asset pipeline

**Installation:**
```bash
# Install Hugo on VPS
wget https://github.com/gohugoio/hugo/releases/download/v0.121.0/hugo_extended_0.121.0_Linux-64bit.tar.gz
tar -xzf hugo_extended_0.121.0_Linux-64bit.tar.gz
sudo mv hugo /usr/local/bin/
```

**Build Process:**
```bash
# Build site
hugo --minify --baseURL "https://example.com"

# Deploy to web root
rsync -avz --delete public/ user@vps:/var/www/html/
```

**Nginx Configuration:**
```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # Cache static assets
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

**Automated Deployment Script:**
```bash
#!/bin/bash
# deploy-hugo.sh

set -e

echo "Building Hugo site..."
hugo --minify --gc

echo "Deploying to VPS..."
rsync -avz --delete \
    --exclude '.git' \
    --exclude 'node_modules' \
    public/ user@vps:/var/www/html/

echo "Deployment complete!"
```

---

### Jekyll Deployment

**Characteristics:**
- Ruby-based
- GitHub Pages compatible
- Mature ecosystem
- Built-in SCSS support

**Installation:**
```bash
# Install Ruby and Jekyll on VPS
sudo apt-get install ruby-full build-essential zlib1g-dev
gem install jekyll bundler
```

**Build Process:**
```bash
# Build site
JEKYLL_ENV=production bundle exec jekyll build

# Deploy
rsync -avz --delete _site/ user@vps:/var/www/html/
```

**Gemfile:**
```ruby
source "https://rubygems.org"

gem "jekyll", "~> 4.3"
gem "webrick", "~> 1.7"

group :jekyll_plugins do
  gem "jekyll-feed"
  gem "jekyll-seo-tag"
  gem "jekyll-sitemap"
end
```

**Deployment Script:**
```bash
#!/bin/bash
# deploy-jekyll.sh

set -e

echo "Installing dependencies..."
bundle install

echo "Building Jekyll site..."
JEKYLL_ENV=production bundle exec jekyll build

echo "Deploying to VPS..."
rsync -avz --delete _site/ user@vps:/var/www/html/

echo "Deployment complete!"
```

---

### Eleventy Deployment

**Characteristics:**
- JavaScript-based
- Flexible templating
- Fast builds
- Modern tooling

**Installation:**
```bash
# Install Node.js and Eleventy
sudo apt-get install nodejs npm
npm install -g @11ty/eleventy
```

**Build Process:**
```bash
# Install dependencies
npm install

# Build site
npm run build

# Deploy
rsync -avz --delete _site/ user@vps:/var/www/html/
```

**package.json:**
```json
{
  "name": "eleventy-site",
  "version": "1.0.0",
  "scripts": {
    "build": "eleventy",
    "serve": "eleventy --serve",
    "deploy": "./scripts/deploy.sh"
  },
  "devDependencies": {
    "@11ty/eleventy": "^2.0.1"
  }
}
```

**.eleventy.js:**
```javascript
module.exports = function(eleventyConfig) {
  // Copy static assets
  eleventyConfig.addPassthroughCopy("src/assets");

  // Minify HTML in production
  if (process.env.NODE_ENV === "production") {
    const htmlmin = require("html-minifier");
    eleventyConfig.addTransform("htmlmin", function(content, outputPath) {
      if (outputPath.endsWith(".html")) {
        return htmlmin.minify(content, {
          useShortDoctype: true,
          removeComments: true,
          collapseWhitespace: true
        });
      }
      return content;
    });
  }

  return {
    dir: {
      input: "src",
      output: "_site"
    }
  };
};
```

---

### Gatsby Deployment

**Characteristics:**
- React-based SSG
- GraphQL data layer
- Rich plugin ecosystem
- Progressive Web App features

**Installation:**
```bash
# Install Node.js and Gatsby CLI
npm install -g gatsby-cli
```

**Build Process:**
```bash
# Install dependencies
npm install

# Build for production
gatsby build

# Deploy
rsync -avz --delete public/ user@vps:/var/www/html/
```

**gatsby-config.js:**
```javascript
module.exports = {
  siteMetadata: {
    title: "My Gatsby Site",
    siteUrl: "https://example.com"
  },
  plugins: [
    "gatsby-plugin-react-helmet",
    "gatsby-plugin-sitemap",
    "gatsby-plugin-manifest",
    {
      resolve: "gatsby-plugin-offline",
      options: {
        precachePages: ["/", "/about/", "/blog/*"]
      }
    }
  ]
};
```

**Nginx Configuration for PWA:**
```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Service worker
    location /sw.js {
        add_header Cache-Control "no-cache";
        proxy_cache_bypass $http_pragma;
        proxy_cache_revalidate on;
        expires off;
        access_log off;
    }

    # Static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

---

## Single Page Applications

### Next.js Static Export

**Characteristics:**
- React framework
- Static export mode
- Image optimization
- API routes (not available in static mode)

**next.config.js:**
```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  images: {
    unoptimized: true // Required for static export
  },
  trailingSlash: true
};

module.exports = nextConfig;
```

**Build Process:**
```bash
# Build static export
npm run build

# Output is in 'out' directory
rsync -avz --delete out/ user@vps:/var/www/html/
```

**package.json:**
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "export": "next build && next export",
    "deploy": "npm run export && ./scripts/deploy.sh"
  }
}
```

**Nginx Configuration:**
```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri.html $uri/ =404;
    }

    # Next.js static assets
    location /_next/static/ {
        alias /var/www/html/_next/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Images
    location ~* \.(jpg|jpeg|png|gif|ico|svg|webp)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

---

### React SPA Deployment

**Characteristics:**
- Client-side routing
- Build optimization
- Code splitting
- Environment variables

**Build Process:**
```bash
# Create React App build
npm run build

# Deploy
rsync -avz --delete build/ user@vps:/var/www/html/
```

**.env.production:**
```env
REACT_APP_API_URL=https://api.example.com
REACT_APP_ENV=production
```

**Nginx Configuration:**
```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
    index index.html;

    # Client-side routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Static assets with versioning
    location /static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # No caching for index.html
    location = /index.html {
        add_header Cache-Control "no-store, no-cache, must-revalidate";
    }
}
```

---

### Vue SPA Deployment

**Characteristics:**
- Vue Router support
- Vuex state management
- Build optimization
- Modern mode

**vue.config.js:**
```javascript
module.exports = {
  publicPath: '/',
  outputDir: 'dist',
  productionSourceMap: false,

  configureWebpack: {
    optimization: {
      splitChunks: {
        chunks: 'all'
      }
    }
  }
};
```

**Build Process:**
```bash
# Build for production
npm run build

# Deploy
rsync -avz --delete dist/ user@vps:/var/www/html/
```

**Nginx Configuration:**
```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
    index index.html;

    # Vue Router history mode
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Chunk files
    location ~* \.(js|css)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

---

## Deployment Automation

### Generic Deployment Script

```bash
#!/bin/bash
# deploy-generic.sh

set -e

# Configuration
VPS_USER="deploy"
VPS_HOST="example.com"
VPS_PATH="/var/www/html"
BUILD_DIR="dist"  # or public, _site, out, etc.

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Starting deployment...${NC}"

# Build
echo "Building application..."
npm run build

# Test build
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}Build directory not found!${NC}"
    exit 1
fi

# Deploy
echo "Deploying to VPS..."
rsync -avz --delete \
    --exclude '.git' \
    --exclude 'node_modules' \
    --exclude '.env' \
    "$BUILD_DIR/" "$VPS_USER@$VPS_HOST:$VPS_PATH/"

# Verify deployment
echo "Verifying deployment..."
ssh "$VPS_USER@$VPS_HOST" "test -f $VPS_PATH/index.html && echo 'Deployment successful!'"

echo -e "${GREEN}Deployment complete!${NC}"
```

### GitHub Actions Workflow

```yaml
name: Deploy to VPS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Build
      run: npm run build

    - name: Deploy to VPS
      uses: easingthemes/ssh-deploy@main
      env:
        SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
        ARGS: "-avz --delete"
        SOURCE: "dist/"
        REMOTE_HOST: ${{ secrets.VPS_HOST }}
        REMOTE_USER: ${{ secrets.VPS_USER }}
        TARGET: "/var/www/html"
```

## Common Issues and Solutions

### Build Failures
- Check Node.js version compatibility
- Verify dependencies are installed
- Review build logs for errors
- Ensure environment variables are set

### Deployment Issues
- Verify SSH access and permissions
- Check disk space on VPS
- Ensure web server is running
- Review deployment script logs

### Runtime Issues
- Check Nginx error logs
- Verify file permissions
- Test client-side routing
- Review browser console for errors

## Related Skills

- `vps-generic-strategies` - Deployment strategy selection
- `vps-laravel-deployment` - Laravel-specific deployment
- `cloudflare-tunneling` - Secure development tunneling

## References

- [Hugo Documentation](https://gohugo.io/documentation/)
- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [Eleventy Documentation](https://www.11ty.dev/docs/)
- [Gatsby Documentation](https://www.gatsbyjs.com/docs/)
- [Next.js Static Export](https://nextjs.org/docs/pages/building-your-application/deploying/static-exports)
- [Create React App Deployment](https://create-react-app.dev/docs/deployment/)
- [Vue CLI Deployment](https://cli.vuejs.org/guide/deployment.html)
