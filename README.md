# Timur Safin's Blog (tsafin.net)

A personal blog and portfolio site built with Jekyll 4.3.4, Ruby 3.4.7, and deployed automatically via GitHub Actions to GitHub Pages.

Based on the [Skinny Bones](http://mmistakes.github.io/skinny-bones-jekyll/) Jekyll theme with extensive customizations.

---

## Requirements

* Ruby 3.4.7
* Bundler 2.6.9+
* Python 3.x (for local testing with http.server)

## Setup

Install dependencies:

```bash
bundle install
```

## Building

### Development Build

Build with development configuration (uses local development domain):

```bash
bundle exec jekyll build --config _config.yml,_config.local.yml
```

### Production Build

Build with production configuration for deployment:

```bash
bundle exec jekyll build
```

## Testing Locally

After building, serve the generated site using Python's built-in server:

```bash
bundle exec jekyll build --config _config.yml,_config.local.yml && python3 -m http.server 4000 -d _site
```

Then access the site at `http://localhost:4000`

### Single Command for Development

For convenience, run both build and serve:

```bash
bundle exec jekyll build --config _config.yml,_config.local.yml && python3 -m http.server 4000 -d _site
```

## Deployment

The site is automatically built and deployed to GitHub Pages on every push to the `source` branch via GitHub Actions.

### Manual Deployment

You can manually trigger a build by:

1. Going to your repository's **Actions** tab
2. Selecting the **Build Jekyll Site** workflow
3. Clicking **Run workflow**

---

## Notable Features

* Jekyll 4.3.4 with Ruby 3.4.7 support
* Dart Sass for stylesheet compilation
* Data files for site navigation, footer, and multiple author support
* Giscus-powered comments (GitHub-based)
* Table of contents and social sharing links
* Automatic GitHub Pages deployment via Actions
* Dual configuration for development and production builds
