#To run, type this in console: runApp("[INSERT PATH NAME]") or can click the run app button in the upper-right corner
#Note may need to check getwd() to get working directory to know what path to type above

library(shiny)
library(RColorBrewer)
library(shinyWidgets)



#Moved rmd code into R file in same directory as app
#TODO: Update source R file if using additional R code beyond this app.R file
source("crosstab_app_functions_template.R")



#add to app inside of fluidpage
#TODO: Fill in Title and update any helptext below
ui <- fluidPage(title = "Test App - Fill Me In",
                
                #Using tabsetPanel to organize the different tabs 
                tabsetPanel(type = "tabs",
                            tabPanel("CrossTab", 
                                     sidebarLayout(
                                       sidebarPanel(
                                         h4("Crosstab Explorer"),
                                         
                                         helpText("Select at least one variable question and demographic variable to display a custom crosstab. The crosstab will display the percentage of poll respondents
                                                  from the selected demographic group that responded to a question.\nType in the box to select an option. You can select more than one per box. Type Total in the demographic
                                                   box to see the topline total."),
                                         
                                         
                                         #MultiSelect 1 - Questions
                                         selectInput("var_question_reg", 
                                                     label = strong("Choose a variable to display: "),
                                                     choices = question_labels,
                                                     selected = "Below is a list of names of people and groups. Please indicate your opinion of each, and how strongly you feel that way. If you have never heard of one, or have heard of them but have no opinion, just indicate that. - Joe Biden",
                                                     multiple= TRUE),
                                         
                                         #MultiSelect 2 - Demographics
                                         selectInput("var_demo_reg", 
                                                     label = strong("Choose a variable to display: "),
                                                     selected = c("Total","Gender"),
                                                     choices = names(crosstab_uf),
                                                     multiple=TRUE,
                                         ),
                                         materialSwitch(inputId = "show_counts",
                                                        label = strong("Show Weighted Counts instead of Percents"), 
                                                        value=FALSE),
                                         
                                         materialSwitch(inputId = "add_subtotal",
                                                        label = strong("Reduce subtotal rows to just totals"), 
                                                        value=FALSE)
                                       ),
                                       
                                       mainPanel(
                                         htmlOutput("message_text"),tableOutput("table") 
                                       )
                                     ),
                            ),
                            
                            tabPanel("Advanced Crosstab",
                                     sidebarLayout(
                                       sidebarPanel(
                                         h4("Advanced Crosstab Explorer"),
                                         helpText("This crosstab can be used to look at the population polled by different demographics. You can also use this to look at the Audience Groups by different demographic breakdowns."),
                                         #MultiSelect 1 - Questions
                                         
                                         selectInput("var_demo_adv", 
                                                     label = "Choose a variable to display in the rows: ",
                                                     choices = append(names(crosstab_uf),question_labels),
                                                     multiple= TRUE),
                                         
                                         #MultiSelect 2 - Demographics
                                         selectInput("var_demo_adv2", 
                                                     label = "Choose a variable to display in the columns: ",
                                                     choices = append(names(crosstab_uf),question_labels),
                                                     multiple=TRUE,
                                         ),
                                         
                                         selectInput("var_demo_adv3", 
                                                     label = strong("Choose a single optional additional demographic to split out results: "),
                                                     selected = "None",
                                                     choices = c("None",names(crosstab_uf)),
                                                     multiple=FALSE,
                                         ),
                                  
                                         materialSwitch(inputId = "show_counts_adv",
                                                        label = strong("Show Weighted Counts instead of Percents"), 
                                                        value=FALSE),
                                         materialSwitch(inputId = "add_subtotal_adv",
                                                        label = strong("Reduce subtotal rows/columns to just totals"), 
                                                        value=FALSE)
                                         
                                       ),
                                       
                                       mainPanel(
                                         htmlOutput("message_text_adv"),tableOutput("table2") 
                                       )
                                     ),
                            )
                            #TODO: Can update with html files generated from the topline templates or remove these
                            #These files will need to live in the same directory as app.R or a directory underneath
                            #tabPanel("Regular Topline", includeHTML("Fill Me In.html")),
                            #tabPanel("Audience Topline", includeHTML("Fill Me In 2.html"))
                ),
                #Update column widths with this CSS
                tags$style(
                  HTML(
                    "th {width: 200px;}"
                  )
                )
)




server <- function(input, output) {
  output$message_text <- renderUI({ 
    #It seems easier to ensure line breaks by using renderUI of HTML vs. renderText
    
    #If there is a message with this label, display it.
    str_messages = "<br>"
    for (q in input$var_question_reg){
      i = names(poll_qs)[which(question_labels==q)]
      message=get_column_message(df[[i]])
      if (message != ""){
        str_messages=paste(str_messages,"<b>",get_label(df[[i]]),"</b> : ",message,"<br><br>") 
      }
    }
    HTML(paste(str_messages,"<br>"))
  })
  
  #For advanced crosstab, display messages
  output$message_text_adv <- renderUI({ 
    #It seems easier to ensure line breaks by using renderUI of HTML vs. renderText
    
    #If there is a message with this label, display it.
    str_messages = "<br>"
    for (q in c(input$var_demo_adv, input$var_demo_adv2)){
      if (q %in% question_labels){
        i = names(poll_qs)[which(question_labels==q)]
        message=get_column_message(df[[i]])
        if (message != ""){
          str_messages=paste(str_messages,"<b>",get_label(df[[i]]),"</b> : ",message,"<br><br>") 
        }
      }
    }
    HTML(paste(str_messages,"<br>"))
  })
  
  #Using renderUI of htmlTable from toplines keeps formatting of labels vs. using renderTable
  output$table <- renderUI(
    
    
    if (!is.null(input$var_question_reg) & !is.null(input$var_demo_reg)){
      HTML(paste("<h5>This crosstab represents the percentage of people who fall into the column category that answered the row response to the selected question(s).</h5>"))
      htmlTable(create_crosstab_app(input$var_question_reg, input$var_demo_reg,input$add_subtotal, input$show_counts),align="c")
    }
    else{
      HTML(paste("<h5>Welcome to the custom crosstab explorer for the survey. This space will be empty until at least one value for each dropdown is selected on the left panel.</h5>"))
    }
  )
  
  
  #Using renderUI of htmlTable from toplines keeps formatting of labels vs. using renderTable
  output$table2 <- renderUI(
    
    if (!is.null(input$var_demo_adv) & !is.null(input$var_demo_adv2) & !is.null(input$var_demo_adv3)){
      HTML(paste("<h5>This crosstab represents the percentage of people who fall into the column category that answered the row response to the selected question(s).</h5>"))
      htmlTable(create_crosstab_app_adv(input$var_demo_adv, input$var_demo_adv2, input$var_demo_adv3,input$add_subtotal_adv, input$show_counts_adv),align="c")
    }
    else{
      HTML(paste("<h5>Welcome to the custom crosstab explorer for the survey. This space will be empty until at least one value for each dropdown is selected on the left panel.</h5>"))
    }
  )
  
}

shinyApp(ui = ui, server = server)