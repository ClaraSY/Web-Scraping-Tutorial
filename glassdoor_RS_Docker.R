library(readr)
library(stringr)
library(tidyverse)
library(httr)
library(rvest)
require(RSelenium)

rd <- remoteDriver(remoteServerAddr = "192.168.99.100",
                   browserName = 'chrome',
                   port = 8080)
rd$open()

rd$setTimeout(type = "page load", milliseconds = 15000)
rd$setImplicitWaitTimeout(10000)


scrape_setup <- function(){
  my_url <<- 'https://www.glassdoor.com/Job/los-angeles-statistician-jobs-SRCH_IL.0,11_IC1146821_KO12,24.htm'
  rd$navigate(my_url)
}
scrape_setup()

rd$getTitle()
rd$navigate(my_url)
rd$screenshot(display = TRUE)

text_xp <- '//*[@id="sc.keyword"]'

text <- rd$findElement(using = 'xpath', text_xp)
text$clearElement()

text$sendKeysToElement(sendKeys = list('statistician'))
text$sendKeysToElement(sendKeys = list(key = 'enter'))

#show filters
filters_xp <- '//*[@id="ExpandFilters"]'
filters <- rd$findElement(using = 'xpath', filters_xp)
filters$clickElement()
rd$screenshot(display = TRUE)

date_select_xp <- '//*[@id="JobFreshnessSelect"]'
date_select <- rd$findElement(using = 'xpath', date_select_xp)
date_select$clickElement()
rd$screenshot(display = TRUE)

# Notice that we cannot!
# Why not? Why is it not visible? It's right there!!!
# because glassdoor are evil!
# examine this code:
# <label class="hidden" for="JobFreshnessSelect">Date Posted</label>
# It is "hidden" from us!!! I guess we're done...

# make JobFreshnessSelect visible.
javascript_string <- "document.getElementById('JobFreshnessSelect').style.display = 'inline';"
rd$executeScript(javascript_string, list())

rd$screenshot(display = TRUE)

date_select_xp <- '//*[@id="JobFreshnessSelect"]'
date_select <- rd$findElement(using = 'xpath', date_select_xp)
date_select$clickElement() # Note we need to click, not click element
rd$screenshot(display = TRUE)

rd$sendKeysToActiveElement(sendKeys = list(key = 'down_arrow',key = 'enter'))

apply_xp <- '//*[@id="ExpandFilters"]/div/div[2]/button[2]'
apply_btn <- rd$findElement(using = 'xpath', apply_xp)
apply_btn$clickElement()
rd$screenshot(display = TRUE)

remove_date_xp <- '//*[@id="ExpandFilters"]/div/div[1]/div[3]/div/i'
remove_date <- rd$findElement(using = 'xpath', remove_date_xp)
remove_date$clickElement()
rd$screenshot(display = TRUE)
#############################

# This is great, but there's a better way!
# it turns out we were using the wrong xpath object!

rd$navigate(my_url)

filters <- rd$findElement(using = 'xpath', filters_xp)
filters$clickElement()

date_select_xp <- '//*[@id="JobSearchFilters"]/div[1]/div[1]/div[2]/div/div[1]/span/p'
date_select <- rd$findElement(using = 'xpath', date_select_xp)
date_select$clickElement()

last_week_xp <- '//*[@id="JobSearchFilters"]/div[1]/div[1]/div[2]/div/div[1]/span/div/ul/li[3]'
last_week <- rd$findElement(using = 'xpath', value = last_week_xp)
last_week$clickElement()

apply_btn <- rd$findElement(using = 'xpath', apply_xp)
apply_btn$clickElement()

#################################

# why did I do that then?
# to introduce you to javascript.
# After we made the invisible visible, one must naturally ask:
# what other magic can we perform?

rd$navigate(url = my_url)
filters <- rd$findElement(using = 'xpath', filters_xp)
filters$clickElement()

js_days_vis <- "document.getElementById('JobFreshnessSelect').style.display = 'inline';"
rd$executeScript(js_days_vis, list())

js_two_days <- 'document.getElementById("JobFreshnessSelect").options[document.getElementById("JobFreshnessSelect").options.length] = new Option("Two Days", 2);'
rd$executeScript(js_two_days, list())

date_select_xp <- '//*[@id="JobFreshnessSelect"]'
date_select <- rd$findElement(using = 'xpath', date_select_xp)
date_select$clickElement()

##########################################

rd$navigate(my_url)

filters <- rd$findElement(using = 'xpath', filters_xp)
filters$clickElement()

js_days_vis <- "document.getElementById('JobFreshnessSelect').style.display = 'inline';"
rd$executeScript(js_days_vis, list())

date_select_xp <- '//*[@id="JobFreshnessSelect"]'
date_select <- rd$findElement(using = 'xpath', date_select_xp)
date_select$clickElement()
rd$sendKeysToActiveElement(sendKeys = list(key = 'down_arrow',key = 'enter'))

js_two_days <- 'document.getElementById("JobFreshnessSelect").options[document.getElementById("JobFreshnessSelect").options.length] = new Option("Two Days", 2);'
rd$executeScript(js_two_days, list())
js_select <- "document.getElementById('JobFreshnessSelect').value = 2;"
rd$executeScript(js_select, list())

js_dist_vis <- "document.getElementById('JobSearchRadiusSelect').style.display = 'inline';"
rd$executeScript(js_dist_vis, list())

js_500_miles <- 'document.getElementById("JobSearchRadiusSelect").options[document.getElementById("JobSearchRadiusSelect").options.length] = new Option("500 Miles", 500);'
rd$executeScript(js_500_miles, list())
js_select <- "document.getElementById('JobSearchRadiusSelect').value = 500;"
rd$executeScript(js_select, list())

apply_btn <- rd$findElement(using = 'xpath', apply_xp)
apply_btn$clickElement()

###################################
# Maybe we should have a few functions by now?
rd$navigate(my_url)

open_filters <- function(){
  filters <- rd$findElement(using = 'xpath', filters_xp)
  filters$clickElement()
}

set_custom_val <- function(rd, id, txt, val){
  # make the hidden field visible:
  js_vis <- paste0("document.getElementById('", id, "').style.display = 'inline';")
  
  # Trigger the onchange event to activate the button:
  js_chng <- paste0('document.getElementById("', id, '").dispatchEvent(new Event("change"));')
  
  # add and select new option:
  js_add <- paste0('document.getElementById("', id, '").options[document.getElementById("', id, '").options.length] = new Option("', txt,'",', val, ');')
  js_sel <- paste0('document.getElementById("', id, '").value = ', val, ';')
  
  js <- paste0(js_vis, js_add, js_sel, js_chng)
  # Engage
  rd$executeScript(js, list())
}

exec_search <- function(){
  apply_btn <- rd$findElement(using = 'xpath', apply_xp)
  apply_btn$clickElement()
}


# But, we should note we didn't have to do any of this...
# we simply could have edited the url directly!

# https://www.glassdoor.com/Job/los-angeles-statistician-jobs-SRCH_IL.0,11_IC1146821_KO12,24.htm?radius=500&fromAge=2


rd$close()






