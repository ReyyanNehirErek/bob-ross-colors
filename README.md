# The Colors of Bob Ross — Data Visualization Redesign
MIS311: Exploratory Data Visualization
Author:Reyyan Nehir Erek

## Overview
This project critiques and redesigns a published data visualization of Bob Ross's
paint color usage across all 31 seasons of *The Joy of Painting* (1983–1994).

The original radial heatmap by Georgios Karamanis was redesigned as a Cartesian
heatmap with a companion ranked bar chart, addressing several visualization
principle violations identified through Wilke (2019).

## Dataset
- **Source:** Jared Wilber, TidyTuesday 2023 Week 08
- **Size:** 403 paintings across 31 seasons, 17 unique paint colors
- **Link:** https://github.com/rfordatascience/tidytuesday/tree/master/data/2023/2023-02-21

## What's Wrong with the Original
- Uses polar coordinates for non-cyclical data (episodes don't loop)
- Arc-length distortion makes inner segments look smaller than outer ones
- No quantitative encoding — frequency of color use is invisible
- 31 separate wheels make cross-season comparison nearly impossible

## What the Redesign Does
- Cartesian heatmap: season on x-axis, color on y-axis, opacity encodes frequency
- Colors ordered by overall usage — most used at top
- Companion bar chart adds exact episode counts for precise comparison
- Warm cream background ensures all 17 colors are visible including light ones

## Tools
R — ggplot2, dplyr, tidyr, stringr, forcats, scales, patchwork, readr

## References

- Original visualization: Georgios Karamanis
- Data: Jared Wilber, TidyTuesday 2023
- Design principles: Wilke, C.O. (2019). *Fundamentals of Data Visualization.*
- Original visualization: Georgios Karamanis
- Data: Jared Wilber, TidyTuesday 2023
- Design principles: Wilke, C.O. (2019). *Fundamentals of Data Visualization.*
