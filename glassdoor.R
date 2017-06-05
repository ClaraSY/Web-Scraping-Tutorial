# Know your enemy
# glassdoor.com

# Let's find data on statistician jobs in Los Angeles.
# Starting url: https://www.glassdoor.com/index.htm

# Looks like javascript, pretty buttons, boxes, and dropdowns.
# When we search we get this url:
# https://www.glassdoor.com/Job/jobs.htm?suggestCount=0&suggestChosen=true&clickSource=searchBtn&typedKeyword=statis&sc.keyword=statistician&locT=C&locId=1146821&jobType=
# it's super long, let's parse it out
# https://www.glassdoor.com/Job/jobs.htm      <- web page
# ?                                           <- start of parameters  
# suggestCount=0&                             <- list of parameters seperated by '&'
#   suggestChosen=true&
#     clickSource=searchBtn&
#       typedKeyword=statis&
#         sc.keyword=statistician&            <- statistician
#           locT=C&locId=1146821&             <- Los Angeles, CA apparently 
#             jobType=

# Lets see what we get when we clean up and construct our own url:
# https://www.glassdoor.com/Job/jobs.htm?sc.keyword=statistician&locT=C&locId=1146821

# great!
# we get our results and a new url:
# https://www.glassdoor.com/Job/
# los-angeles-statistician-jobs-SRCH_IL.0,11_IC1146821_KO12,24.htm

# let's experiment a bit and see what happens when we change the url slightly:
# nothing good or interesting.

# note: 663 listings, and page 1 of 22.
# let's see if and how the url changes when we browse to the next page:
# we get a pop up: "Be the first to know about new jobs"
# so we need to be aware of full page popups and that we might need to dismiss them.
# also, new url:
# https://www.glassdoor.com/Job/
# los-angeles-statistician-jobs-SRCH_IL.0,11_IC1146821_KO12,24_IP2.htm
# los-angeles-statistician-jobs-SRCH_IL.0,11_IC1146821_KO12,24.htm
# what has changed? they added '_IP2' to the url.
# This feels like a page counter.
# try changing it to page 3.
# works!
# What about page 10?
# works!
# page 100?
# I got a time out error due to high volume!
# these are 'countermeasures!
# the bottom of the page says page x of 22. We will use this to manage our scrape.
# I suspect they are not timing us out yet, but that's the error message they use for a bad url.
# try page 23.
# different error. looks like we only get the high volume warning on high page numbers.

# Now let's look at a listing page.
# url stays the same, anooying.
# opens view in same window, ugh!
# but, what if we copy the url and open it in a new window instead of clicking?
# Eureka!!!!

# New url!
# https://www.glassdoor.com/job-listing/
# data-scientist-%C3%A2-research-informatics-city-of-hope-JV_IC1146821_KO0,37_KE38,50.htm?
# jl=2382714396&ctt=1496611819151
# long url, looks like the pass information to be displayed in the url.
# the two parameters look important though, what are they?

# guess: job listing and ???
# ctt doesn't seem important, we can see the page without it.
# what about changing the job listing?
# looks like it can't find that page.
# what if we keep the url and put in another job listing?
# https://www.glassdoor.com/partner/jobListing.htm?pos=1303&ao=170885&s=58&guid=0000015c7503537aadc6e938a204083d&src=GD_JOB_AD&t=SR&extid=1&exst=OL&ist=&ast=OL&vt=w&slr=true&rtp=0&cb=1496611771651&jobListingId=1584590944
# 1584590944
# so lets try the first url with the second jl.
# 
# https://www.glassdoor.com/job-listing/
# data-scientist-%C3%A2-research-informatics-city-of-hope-JV_IC1146821_KO0,37_KE38,50.htm?
# jl=1584590944
# found the page no problem!!!

# Let's see how badly we can mangle the url and still get the listing!
# https://www.glassdoor.com/job-listing/data-scientist.htm?jl=1584590944
# https://www.glassdoor.com/job-listing/-JV_IC1146821_KO0,37_KE38,50.htm?jl=1584590944
# looks like just need the -JV, we can drop the location ID and the rest of the code to follow.
# https://www.glassdoor.com/job-listing/-JV.htm?jl=1584590944
# I suspect -JV indicates "Job View"

# Great!!!

# Now we have a strategy! Two parts:
# First, scrape the directory for job listing ids
# Second, go to each page and scrape the job listing!

# so we will need two pieces of code to accomplish this.

# but first, let's look at filtering!

# DAMN! Filtering does not! change the url!
# This is a capital-'P' Problem.

# Time to inspect!
