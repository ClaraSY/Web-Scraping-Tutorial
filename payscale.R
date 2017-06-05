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
  my_url <<- 'http://www.payscale.com/college-roi'
  rd$navigate(my_url)
}
scrape_setup()
lm_btn_xp <- '//*[@id="collegeRoiContent"]/div/div/div[2]/div/div[1]/a' 
lm_btn <- rd$findElement(using = 'xpath', lm_btn_xp)
for(i in 1:130){
  lm_btn$clickElement()
}

table_row_xp <- '//*[@id="collegeRoiContent"]/div/div/div[2]/table/tbody/tr'
table_row <- rd$findElements(using = 'xpath', value = table_row_xp)

clean_row <- function(row){
  x <- str_split(string = row$getElementText() %>% unlist,pattern = '\n',simplify = T)
  x <- str_replace_all(string = x, pattern = '[$,\\%]| Years', '')
  y <- str_split(string = x[3], pattern = '[\\s+]') %>% unlist
  row <- c(x[1:2],y)
  row[row == '-' | row == 'N/A'| row == '<N/A>'] <- NA
  return(row)
}

z <- sapply(table_row, clean_row)

column_names <- c('Rank', 'School Name', '20 Year Net ROI', 'Total 4 Year Cost', 'Graduation Rate', 'Typical Years to Graduate', 'Average Loan Amount') 
pay_scale_df <- as.data.frame(t(z))
names(pay_scale_df) <- column_names

pay_scale_df$'School Type' <- NA
pay_scale_df[str_detect(string = pay_scale_df$`School Name`, pattern = '(Federal)'),]$'School Type' <- 'Federal'
pay_scale_df[str_detect(string = pay_scale_df$`School Name`, pattern = '(Private)'),]$'School Type' <- 'Private'
pay_scale_df[str_detect(string = pay_scale_df$`School Name`, pattern = '(In-State)'),]$'School Type' <- 'In-State'
pay_scale_df[str_detect(string = pay_scale_df$`School Name`, pattern = '(Out-of-State)'),]$'School Type' <- 'Out-of-State'

pay_scale_df$`School Name` <- str_replace(string = pay_scale_df$`School Name`,
                                          pattern = '\\(Federal\\)',
                                          replacement = '')
pay_scale_df$`School Name` <- str_replace(string = pay_scale_df$`School Name`,
                                          pattern = '\\(Private\\)',
                                          replacement = '')
pay_scale_df$`School Name` <- str_replace(string = pay_scale_df$`School Name`,
                                          pattern = '\\(In-State\\)',
                                          replacement = '')
pay_scale_df$`School Name` <- str_replace(string = pay_scale_df$`School Name`,
                                          pattern = '\\(Out-of-State\\)',
                                          replacement = '')
pay_scale_df$`Rank` <- str_replace(string = pay_scale_df$`Rank`,
                                          pattern = ' \\(tie\\)',
                                          replacement = '')
library(rvest)


class(pay_scale_df$Rank) <- 'integer'
pay_scale_df$`20 Year Net ROI` <- as.numeric(as.character(pay_scale_df$`20 Year Net ROI`))
pay_scale_df$`Total 4 Year Cost` <- as.numeric(as.character(pay_scale_df$`Total 4 Year Cost`))
pay_scale_df$`Graduation Rate` <- as.numeric(as.character(pay_scale_df$`Typical Years to Graduate`))
pay_scale_df$`Average Loan Amount` <- as.numeric(as.character(pay_scale_df$`Average Loan Amount`))

idx <- (is.na(pay_scale_df$`20 Year Net ROI`))
pay_scale_df[idx,]
