library(httr)
library(jsonlite)
json_file <- GET(url = 'http://api.glassdoor.com/api/api.htm?v=1&format=json&t.p=158132&t.k=iSrHX9McCHo&action=employers')
json_file$all_headers

my_df <- fromJSON(content(json_file,as = 'text')) %>% as.data.frame
str(my_df)

base <- 'http://api.glassdoor.com/api/api.htm?'
p_id <- 't.p=158132'
p_key <- 't.k=iSrHX9McCHo'
format <- 'format=json'
l <- 'l=los%20angeles'
action <- 'action=employers'
pn <- paste0('pn=', 1)

my_url <- paste0(base,paste0(c(p_id, p_key, format, l, action),collapse = '&'))
resp <- GET(url = my_url)
my_df <- fromJSON(content(resp,as = 'text')) %>% as.data.frame
rownames(my_df)
rownames(new_df)

for (i in 2:2519){
  print(i)
  pn <- paste0('pn=', i)
  my_url <- paste0(base,paste0(c(p_id, p_key, format, l, pn, action),collapse = '&'))
  resp <- GET(url = my_url)
  new_df <- fromJSON(content(resp,as = 'text')) %>% data.frame()
  rownames(new_df) <- as.character(as.numeric(rownames(new_df)) + max(as.numeric(rownames(my_df))))
  x <- names(new_df)[which(!(names(new_df) %in% names(my_df)))]
  if(length(x)>0){my_df[x] <- NA}
  x <- names(my_df)[which(!(names(my_df) %in% names(new_df)))]
  if(length(x)>0){new_df[x] <- NA}
  ord <- match(names(my_df), names(new_df))
  new_df <- new_df[ord]
  rownames(my_df) <- NULL
  rownames(new_df) <- 11:20
  temp_df <- rbind(my_df, new_df)
  glimpse(my_df$response.employers.ceo)
  
  Sys.sleep(time = 8)
}





df1 <-data.frame(x=c(1,2,3))
df1
df2 <-data.frame(x=c(2,3,7))
df2
rbind(df1,df2)
