# 🏢 SandP1500 Constituents Wikipedia Scraper

This R script scrapes historical constituents of the **S&P 500**, **S&P 400**, and **S&P 600** from their respective Wikipedia pages:

- [S&P 500](https://en.wikipedia.org/wiki/List_of_S%26P_500_companies)  
- [S&P 400](https://en.wikipedia.org/wiki/List_of_S%26P_400_companies)  
- [S&P 600](https://en.wikipedia.org/wiki/List_of_S%26P_600_companies)  

It reconstructs the composition of each index month-by-month, working backward from the current date, using both current constituents and historical change tables.

This script is inspired by https://medium.com/@rodrigo.maciel.rubio/web-scraping-historical-s-p-500-constituents-for-quantitative-trading-da29596d10cb.

---

## 🔧 How to Use

This script is designed for **any R user, even beginners**. Just follow these steps:

### 1. Install R (and optionally RStudio)

If you haven't already, install R from [CRAN](https://cran.r-project.org/) and optionally [RStudio](https://posit.co/download/rstudio-desktop/).

### 2. Set the time range

Open the script and set the range of years you're interested in. These are the only two lines you need to edit:

```r
from_year <- 2000  # Change to your desired starting year
to_year <- 2023    # Change to your desired ending year
```

### 3. Run the script

The script will:

- Automatically install required packages (`tidyverse`, `rvest`)
- Create a folder called `SandP1500_data/`
- Scrape and reconstruct historical index membership data for S&P 500, S&P 400 and S&P 600
- Save separate CSV files for each index
- Combine all into a master dataset:
  - `SandP1500_data_year_ticker_wikipedia.csv`

---

## 📁 Output Files

All CSV files are saved in the `SandP1500_data/` folder:

- `SandP500_data_year_ticker_wikipedia.csv`
- `SandP400_data_year_ticker_wikipedia.csv`
- `SandP600_data_year_ticker_wikipedia.csv`
- `SandP1500_data_year_ticker_wikipedia.csv` *(combined dataset)*

Each row represents a stock’s membership in a given year, along with the index it belonged to.

---

## 📝 Notes

- The script works **backwards** in time using the change logs on Wikipedia.
- The output is cleaned and deduplicated by `year` and `ticker`.
- Wikipedia pages may change structure in the future; if errors appear, verify the relevant table nodes still exist on the page.

---

## 📌 Example Use Case

Want to analyze index changes over time? This script can help you:

- Reconstruct historical index portfolios
- Study turnover or survival of companies
- Analyze performance of entrants/exits over the years
