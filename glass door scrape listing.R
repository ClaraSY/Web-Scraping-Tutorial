# glassdoor scrape
# inspection:

# Title
# '//*[@id="HeroHeaderModule"]/div[3]/div[2]/h2'

# Employer
# '//*[@id="HeroHeaderModule"]/div[3]/div[2]/span[1]'

# Posted number of days ago
# '//*[@id="HeroHeaderModule"]/div[4]/div[2]/span'

# Job description
# '//*[@id="JobDescContainer"]/div[1]'

# Rating Number
# '//*[@id="ReviewsEmpStats"]/div/div[1]/div[1]'

title_xp <- '//*[@id="HeroHeaderModule"]/div[3]/div[2]/h2'
employer_xp <- '//*[@id="HeroHeaderModule"]/div[3]/div[2]/span[1]'
days_ago_xp <- '//*[@id="HeroHeaderModule"]/div[4]/div[2]/span'
job_desc_xp <- '//*[@id="JobDescContainer"]/div[1]'
rating_xp <- '//*[@id="ReviewsEmpStats"]/div/div[1]/div[1]'

make_empty_data_frame <- function(){
  df_jobs <- data.frame(Job_ID = numeric(),
                        Title = character(),
                        Employer = character(),
                        Date_Posted = as.Date(x = integer(0), origin = "1970-01-01"),
                        Job_Description = character(),
                        Employer_Rating = numeric())
  return(df_jobs)
}

make_new_row <- function(){
  title <- rd$findElement(using = 'xpath', title_xp)$getElementText() %>% unlist
  day <- rd$findElement(using = 'xpath', days_ago_xp)$getElementText() %>% unlist
  day <- ifelse(day == 'Today', 0, str_extract_all(day,'[1-9]') %>% unlist %>% paste0 %>% as.integer())
  job_desc <- rd$findElement(using = 'xpath', job_desc_xp)$getElementText() %>% unlist
  rd$setImplicitWaitTimeout(200)
  employer <- try(rd$findElement(using = 'xpath', employer_xp)) 
  if(class(employer) == 'webElement'){
    employer <- employer$getElementText() %>% unlist
  } else{
    employer <- NA
  }
  rating <- try(rd$findElement(using = 'xpath', rating_xp), silent = TRUE) 
  rd$setImplicitWaitTimeout(10000)
  if(class(rating) == 'webElement'){
    rating <- rating$getElementText() %>% unlist %>% as.numeric
  } else{
    rating <- NA
  }
  new_row <- data.frame(Job_ID = jl,
                        Title = title,
                        Employer = employer,
                        Date_Posted = as.Date(Sys.Date() - day, origin = "1970-01-01"),
                        Job_Description = job_desc,
                        Employer_Rating = rating)
  return(new_row)
}

df_jobs <- make_empty_data_frame()

for(jl in ids){
  my_url <- paste0(base_url, jl)
  rd$navigate(my_url)
  new_row <- make_new_row()
  df_jobs <- rbind(df_jobs, new_row)
}

View(head(df_jobs))
