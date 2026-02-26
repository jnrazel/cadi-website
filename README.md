# CADI – Climate-Driven Agricultural Decline Index

An interactive website presenting high-resolution estimates of how climate change affects agricultural productivity worldwide.

## Overview

CADI quantifies climate-driven changes in attainable crop yields on a global 5 arc-minute grid (approximately 10×10 km), using data from the [Global Agro-Ecological Zones v5](https://gaez.fao.org) (GAEZ v5) model developed by FAO and IIASA. The website visualises both **observed changes** (1981–2000 vs 2001–2020) and **future projections** (2021–2040 through 2081–2100 under SSP5-8.5), expressed as changes in the number of people that could be fed per grid cell.

## Key features

- **Interactive maps** with absolute and relative change views, time-period slider, and toggleable scenario layers
- **Concepts page** explaining attainable yield, caloric production, and the empirical rationale for the SSP5-8.5 scenario
- **Methods page** documenting the no-adaptation framework, data sources, and index construction
- Responsive design for desktop and mobile

## Structure

- `index.html` – Landing page with key findings
- `concepts.html` – Explanations of core concepts
- `about.html` – Methodological documentation
- `team.html` / `partners.html` – Project team and institutional partners
- `ssp585_absolute.html`, `ssp585_relative.html`, `observed_absolute.html`, `observed_relative.html` – Map explorer pages (generated from `code/map_template_comparable.Rmd`)
- `code/` – R Markdown template and map generation script
- `css/cadi-style.css` – Shared stylesheet
- `img/` – Team photos and partner logos

## Built with

R Markdown, Leaflet, GitHub Pages

## Authors

Laura Mayoral, Hannes Mueller, Björn Komander, János Szentistványi
