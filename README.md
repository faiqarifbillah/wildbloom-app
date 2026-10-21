# WildBloom

Offline Flutter app for browsing Malaysian wildflowers from the LIAR.KL catalogue.

## Features

- A-Z browsing by letter
- Search by species name
- Species detail pages with habitat, season, and conservation status
- Full-screen photo viewing
- Save species to a personal collection (Simpan Koleksi)
- Herbarium view
- List and grid layouts

## Upcoming

- Plant recognition from photos (Pengecaman tab and camera button). Planned, not yet implemented.
- Distribution map (Peta Taburan). Placeholder for now.

## Screenshots

<!-- Add screenshots to docs/screenshots/ and uncomment the lines below -->
<!-- ![Species list](docs/screenshots/list.png) -->
<!-- ![Species detail](docs/screenshots/detail.png) -->
<!-- ![Herbarium](docs/screenshots/herbarium.png) -->

## Tech stack

- Flutter and Dart
- Google Fonts (Playfair Display, Plus Jakarta Sans)
- Bundled JSON dataset (`assets/flora.json`)

## Getting started

    flutter pub get
    flutter run

## Status

- Prototype. The app currently reads a bundled dataset and works offline.
- Planned: connect the app to the live LIAR.KL database so lecturers can access it from their phone. Preparing for go-live.
- The bundled dataset is being synced with the LIAR.KL database before go-live.
- Photos are not included in this repository.

## Author

Faiq Arifbillah, Universiti Tenaga Nasional (UNITEN).
