library(sjPlot)
library(tidyverse)
library(Hmisc)
library(weights)
library(descr)
library(car)
library(anesrake)
library(openxlsx)
library(sjlabelled) #Adding this library to more easily access labels from dataframe columns
library(haven)
library(htmlTable)
library(comprehenr) #For Python like list comprehension
library(wordcloud)
library(tm)
library(scales)
#this needs to come after tidyverse, b/c needs to be loaded after haven
library(expss)
library(rlist)

#Reading in the data
#This is generating from running the Import_final.Rmd notebook
#This is the data already recoded and weighted
#TODO: Change filename
file_name = "raw_poll_post_weighting_test.sav"
df = haven::read_spss(file_name)

#TODO If some labels on question answers are too long, Qualtrics cuts them off in the data file. Update this code with the full string from the poll text to display properly in generated toplines/crosstabs or delete this chunk if not relevant

#Question # to be updating
q = "Q98" 

#Text response text to be updating
#val_lab(df[[q]]) = c("Fill me in: Text Response 1"=1, "Fill me in: Text Response 2" =2, "Fill me in: Text Response 3"=3, "Fill me in: Text Response 4"=4, "Fill me in: Text Response 5"=5)
var_lab(df[[q]]) = "This question will focus on a hypothetical scenario, and the next question will add additional details. The scenario begins as follows:
There is a shortage of [Ice Cream/Frozen Yogurt] (i.e. [IC/Froyo]) in the country. There is a proposal to pass legislation to produce more [Ice Cream/Frozen Yogurt]. 

Would you support or oppose this legislation? Please indicate how strongly you feel that way."

#Need to convert back to haven labelled vs. xpss label after resetting the labels
df[[q]] = haven::labelled(df[[q]],val_lab(df[[q]]),var_lab(df[[q]]))


#Add labelled class and rename audience to df
expss_digits(digits = 0) #Round digits
df = add_labelled_class(df) 


#Regex to identify questions for questions vs demographics columns

#TODO: Filter out any questions that can't show up on a toplines/crosstab (i.e. open response will be removed)
#poll_qs is any columns that start with Q or D_Split or mover_

poll_qs = df %>% 
  select(matches("^Q\\d+|mover\\S*|^D_Split$"))%>%
  select(-c("Q5", "Q13", "Q14", "Q38_9_TEXT", "Q40_9_TEXT")) #Questions that we don't want to show in toplines like open response, other text

#crosstab_qs is any columns that start with D, including D_Split
crosstab_qs = df %>% 
  select(matches("^D_.*"))


#Setting user friendly display names of demographic column names
#TODO may need to update these if slightly different demographic names in new poll
crosstab_uf = c("Registered To Vote"="D_RegVote","Gender"="D_Gender","Age range"="D_Age","State"="D_state","Political Identity"="D_PID",
         "Education"="D_Edu","Religion"="D_Religion","Political Ideology" = "D_Ideo_1", "Marital Status" = "D_Marital", 
         "Parent Yes/No" = "D_Parental", "Income" = "D_Income", "Employment"="D_Employment", "Urbanicity" = "D_Urbanicity",
         "Military" = "D_Military", "Total" = "D_Toplines", "Split" = "D_Split", "Do you personally know any people who are Muslim?" = "D_KnowAMuslim",
         "Did you, or do you personally know someone who came to America as a refugee?" = "D_KnowARefugee", "Race (Condensed)"="D_Race_binary",
         "Age (Condensed)" = "D_Age_cond3", "Political Identity (Condensed to include leaners in party)"="D_PID_party",
         "Political Identity (Condensed to include leaners in independent)"="D_PID_ind", "Education (Condensed)" = "D_Edu_cond",
         "Political Ideology (Condensed)" = "D_Ideo_cond", "Region of US" = "D_Region", "Religion (Condensed)" = "D_Religion_cond",
         "Education & Race (Condensed)" = "D_Edu_race", "RI Audience Categories" = "RI_Audience_categories", "PS Audience Categories" = "PS_Audience_categories",
         "Race" = "D_Race")


##############
##############
#Additional app code

#Get the labels for the variables
get_label_list = function(var_names){
  output = to_list(for (i in var_names) get_label(df[[i]]))
  return (output)
}

question_labels = get_label_list(names(poll_qs))


#TODO Update file_name path or remove this chunk if no messages
#Poll messaging
#Reading in a table that maps the message text to the message labels
messages = read_csv("message_codes.csv")
messages_vec = messages$message
names(messages_vec) = messages$var_lab

#Message helper functions to apply any message strings that didn't come in from Qualtrics
get_column_message = function (col_vec) {
  #Getting the short message label like Preparation
  message_label = var_lab(col_vec)
  
  #Splitting the short message label to remove the Emotion appending of E - Selected Choice
  message_label = strsplit(message_label," E - Selected Choice")[[1]]
  
  message_text = ""
  if (message_label %in% names(messages_vec)){
    message_text = messages_vec[[message_label]] 
  }
  return (message_text)
}

update_columns_with_message_text = function(df,col){
  message_text = get_column_message(df[[col]])
  #Splitting the short message label to remove the Emotion appending of E - Selected Choice
  message_label = var_lab(df[[col]])
  message_label = strsplit(message_label," E - Selected Choice")[[1]]
  
  #Check if message_text is empty, if so, don't append the text and ":"
  if (message_text!=""){
    var_lab(df[[col]]) = paste("<b>",message_label,":</b>",message_text) 
  }
  else{
    var_lab(df[[col]]) = paste("<b>",message_label,"</b>")
  }
  return (df)
}


#TODO: Will need to update for new poll
#List of questions from the Poll that do not need subtotals
no_subtotal_qs = c("Q10","Q38","Q40", "Q97", "mover_Q10_Q97", "mover_cond_Q10_Q97")

#Helper function used to return a list of variables that will be used in the cro tables
get_var_list = function(input,add_bool){
  column_list = list()
  for (j in input){
    if (j %in% names(crosstab_uf)){
      column_list = list.prepend(column_list, df[[crosstab_uf[j]]])
    }
    else{
      i = names(poll_qs)[which(question_labels==j)]
      
      #not in subtotals, just add column to list
      if (i %in% no_subtotal_qs){
        column_list=list.prepend(column_list,df[[i]])
      }
      
      #has subtotal so add subtotal of column to list
      else{
        column_list=list.prepend(column_list,subtotal(df[[i]],1:2,3:4,prefix="Total: ",position = "above",add=add_bool))
        
      }
    }
  }
  return (column_list)
}


create_crosstab_app_adv = function(input1,input2,input3,add_bool=FALSE,hide_rows=FALSE, hide_columns=FALSE, show_counts=FALSE) {
  add_bool=!add_bool
  
  #column1 for the demographics
  column1=get_var_list(input1, add_bool)
  
  #Column 2 for the demographics
  column2=get_var_list(input2, add_bool)
  
  
  #Now check if input3 not None
  if (!is.null(input3) & input3!="None"){
    
    #Want to hide input3 label column
    temp = df
    var_lab(temp[[crosstab_uf[input3]]]) = "|" #setting variable label to "|" hides label from tables
    
    if (show_counts){
      ct = cro_cases(temp[[crosstab_uf[input3]]], column2, column1,
                     weight=df$weightcompressed,
                     total_row_position = "none")
    }
    else{
      
      ct = cro_cpct(temp[[crosstab_uf[input3]]], column2, column1,
                    weight=df$weightcompressed,
                    total_row_position = "none")
    }
  }
  else{
    if (show_counts){
      ct = cro_cases(column1, column2,
                     weight=df$weightcompressed, 
                     total_row_position = "none")
    }
    else{
      ct = cro_cpct(column1, column2,
                    weight=df$weightcompressed, 
                    total_row_position = "none")
    }
  }
  
  #Hide any rows that don't start with Total
  if (hide_rows){
    match_vec = match_row(contains("Total: "),ct) #Use this to find rows that start with "Total" and remove if not
    ct = ct[!is.na(match_vec)]
  }
  
  #Hide any columns that don't start with column
  if (hide_columns){
    ct = keep(ct, (contains("row_labels")| contains("Total")))
  }
  
  #Changing any na values in the table to 0
  ct[is.na(ct)] = 0
  return (ct)
}

#Use for the app to send two columns to crosstab with
create_crosstab_app = function(input1,input2,add_bool=FALSE,hide_rows=FALSE, show_counts=FALSE) {
  add_bool=!add_bool
  
  #column1 for the questions
  column1=list()
  
  #Column 2 for the demographics
  column2=to_list(for (j in input2) list(df[[crosstab_uf[j]]]))
  
  #Looping through the questions to add subtotals where applicable
  for (q in input1){
    #q is the quesiton label
    #need to convert to question #
    i = names(poll_qs)[which(question_labels==q)]
    
    #not in subtotals, just add column to list
    if (i %in% no_subtotal_qs){
      column1=list.prepend(column1,df[[i]])
    }
    
    #has subtotal so add subtotal of column to list
    else{
      column1=list.prepend(column1,subtotal(df[[i]],1:2,3:4,prefix="Total: ",position = "above",add=add_bool))
      
      
    }
  }
  #Now put together the table
  if (show_counts){
    ct = cro_cases(column1, column2,
                   weight=df$weightcompressed, 
                   total_row_position = "none")
  }
  else{
    ct = cro_cpct(column1, column2,
                  weight=df$weightcompressed, 
                  total_row_position = "none")
  }
  
  #Hide any rows that don't start with Total
  if (hide_rows){
    match_vec = match_row(contains("Total: "),ct) #Use this to find rows that start with "Total" and remove if not
    ct = ct[!is.na(match_vec)]
  }
  
  
  
  #Changing any na values in the table to 0
  ct[is.na(ct)] = 0
  return (ct)
}



update_table_styling = function(df,caption){
  #where contains the position of where the styling will take effect
  #Note that where starts at index 0
  where = rbind(c(5,1),c(6,1),c(6,2),c(6,3),c(7,2),c(7,3))
  style = c("font-weight: bold;","font-weight: bold;")
  css.cell = matrix("",nrow(df),ncol(df))
  css.cell[where] = style
  return (htmlTable(df,css.cell=css.cell,caption=caption,align="lccc"))
}