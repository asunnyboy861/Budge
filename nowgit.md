# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | Budge |
| **Git URL** | git@github.com:asunnyboy861/Budge.git |
| **Repo URL** | https://github.com/asunnyboy861/Budge |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/Budge/ | ✅ Active |
| Support | https://asunnyboy861.github.io/Budge/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/Budge/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/Budge/terms.html | ✅ Active |

## Repository Structure

```
Budge/
├── Budge/                         # iOS App Source Code
│   ├── Budge.xcodeproj/           # Xcode Project
│   ├── Budge/                     # Swift Source Files
│   │   ├── Views/
│   │   │   ├── Onboarding/
│   │   │   ├── Today/
│   │   │   ├── AddTransaction/
│   │   │   ├── Trends/
│   │   │   ├── Settings/
│   │   │   └── Components/
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   ├── Services/
│   │   └── Helpers/
│   └── ...
├── docs/                          # Policy Pages (GitHub Pages source)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/
│   └── deploy.yml
├── us.md
├── keytext.md
├── capabilities.md
├── icon.md
├── price.md
└── nowgit.md
```
