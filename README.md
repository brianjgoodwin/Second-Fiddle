# Second Fiddle

A focused macOS utility for building SQL queries from CSV data - built for one specific job, and it does it well.

## What

Second Fiddle is a personal productivity tool designed to solve a specific workflow problem: quickly building SELECT DISTINCT SQL queries from CSV files containing past marketing campaign data.

Built for a day job that involves managing email and print marketing recipient lists, this app provides a simple search UI that wraps CSV data and generates SQL queries - saving significant time compared to one-at-a-time queries in some database systems.

This is a uni-tasker by design: it does one thing, does it well, and nothing more.

## Tech Stack

- **Platform:** macOS 15.5+
- **Language:** Pure Swift
- **Framework:** AppKit/Cocoa
- **Xcode:** 16+ (tested and working)
- **Dependencies:** None

## Setup & Run

### Prerequisites

- macOS 15.5 or later
- Xcode 16 or later

### Running Locally

1. Clone the repository
2. Open `Second Fiddle.xcodeproj` in Xcode
3. Build and run (⌘R)

No additional setup, configuration, or dependencies required.

### Testing

The app requires CSV files to function. Sample CSV files are not provided - use your own data files for testing.

## Deployment

### Current State

Personal use only - built and run locally. Not available on the App Store.

### Future Plans

- Extract the core UI scaffold as a reusable macOS app template
- Create GitHub releases for direct download
- Document the template for use in future single-purpose utility apps

## Status

**Actively maintained** - Personal use only

Repository: [github.com/brianjgoodwin/Second-Fiddle](https://github.com/brianjgoodwin/Second-Fiddle) (public)

**Single user:** Built specifically for my workflow, maintained as needed.

## Features

### Core Functionality
- **CSV import** - Load files containing marketing campaign/concert data
- **Search interface** - Simple UI for filtering and searching records
- **SQL query generation** - Automatically builds SELECT DISTINCT queries
- **Workflow optimization** - Significantly faster than manual database queries

### Use Case
Primary use: Building recipient lists for email and print marketing campaigns by querying past concert/event data. Designed to streamline a repetitive task in arts marketing workflows using Tessitura or similar systems.

## Notes

This app represents the "do one thing well" philosophy of software design. It solves a specific, repetitive problem in my day job workflow without feature bloat or unnecessary complexity.

The core UI scaffold may be valuable as a template for future single-purpose macOS utilities - simple, clean, focused apps that solve one problem extremely well.

**Why "Second Fiddle"?** A play on the musical term, fitting for an app used in arts/concert marketing work. It's the supporting player that makes the main show run smoothly.
