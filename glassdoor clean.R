# click the filter toggle.
open_filters <- function(){
  filters <- rd$findElement(using = 'xpath', filters_xp)
  filters$clickElement()
}

# set whatever custom values you want.
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

# execute the search.
exec_search <- function(){
  apply_btn <- rd$findElement(using = 'xpath', apply_xp)
  apply_btn$clickElement()
}

# check for pop-up
check_pop_up <- function(){
  pop_up_xp <- '//*[@id="JAModal"]/div/div/div[2]/div/button'
  rd$setImplicitWaitTimeout(200)
  pop_up <- try(rd$findElement(using = 'xpath', pop_up_xp), silent = TRUE)
  if(class(pop_up) == 'webElement'){
    if(unlist(pop_up$isElementDisplayed())){
      pop_up$clickElement()
    } 
  } else{
    
  }
  rd$setImplicitWaitTimeout(10000)
}

# collect all the links.
get_links <- function(){
  link_xp <- '//*[@id="MainCol"]/div/ul/li/div[2]/div[1]/div[1]/a'
  links <- rd$findElements(using = 'xpath',value = link_xp)
  get_url <- function(x){
    unlist(x$getElementAttribute(attrName = 'href'))
  }
  y <- sapply(links,get_url)
  return(y)
}

# get the jl from each link
parse_links <- function(links){
  get_jlid <- function(x){
    str_split(string = x, pattern = '&jobListingId=', simplify = TRUE)[2]
  }
  y <- sapply(links, get_jlid)
  names(y) <- NULL
  return(y)
}

# Turn the page...
advance_page <- function(){
  done <- FALSE
  next_xp <- '//*[@id="FooterPageNav"]/div/ul/li[7]'
  next_page <- rd$findElement(using = 'xpath', next_xp)
  look_for_last_xp <- '//*[@id="FooterPageNav"]/div/ul/li[6]'
  lfl <- rd$findElement(using = 'xpath', look_for_last_xp) 
  last_page <- lfl$getElementAttribute(attrName = 'class') %>% unlist == 'page current last'
  if(!last_page){
    next_page$clickElement()
  } else {
    done <- TRUE
  }
  return(done)
}

# Scrape the ids
scrape_ids <- function(){
  ids <- c()
  done <- FALSE
  while(!done){
    check_pop_up()
    links <- get_links()
    ids <- c(ids,parse_links(links))
    done <- advance_page()
  }
  return(ids)
}

rd$navigate(my_url)
open_filters()
set_custom_val(rd, 'JobFreshnessSelect', 'Two Days', 2)
set_custom_val(rd, 'JobSearchRadiusSelect', '500 Miles', 500)
exec_search()
ids <- scrape_ids()