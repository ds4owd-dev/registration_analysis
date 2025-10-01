# Registration Analysis

This repository contains a descriptive and exploratory analysis of the data collected through the registration form for the course [Data Science for Open WASH data course](https://ds4owd-002.github.io/website/).

## Setup

Install dependencies using renv:
```r
renv::restore()
```

Share access to sensitiva data files with Kobo and setup once:
```r
kobo_setup(
     url = "https://kobo.humanitarianresponse.info",
     token = "your_api_token"
   )
```

If data is private, use the private submodule
```bash
/registration_analysis_private/{data, output}
```