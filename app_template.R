#To run, type this in console: runApp("Desktop/Poll_analysis_code_dev/crosstab_app/")
#runApp("App-1", display.mode = "showcase")
#Note may need to check getwd()

library(shiny)
library(RColorBrewer)
library(shinyWidgets)



#Moved rmd code into R file in same directory as app
#TODO: Update source R file
source("crosstab_app_functions_template.R")



#add to app inside of fluidpage
#TODO: Fill in Title and update any helptext below
ui <- fluidPage(title = "Fill Me In",
                
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
                                         
                                         materialSwitch(inputId = "add_subtotal",
                                                        label = strong("Replace rows already in subtotals"), 
                                                        value=FALSE),
                                         
                                         materialSwitch(inputId = "hide_non_total_rows",
                                                        label = strong("Hide non Total rows"), 
                                                        value=FALSE
                                                        
                                         )
                                       ),
                                       
                                       mainPanel(
                                         htmlOutput("selected_var"),tableOutput("table") 
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
                                         
                                         materialSwitch(inputId = "add_subtotal_adv",
                                                        label = strong("Replace rows/columns already in subtotals"), 
                                                        value=FALSE),
                                         materialSwitch(inputId = "hide_non_total_rows_adv",
                                                        label = strong("Hide non Total rows"), 
                                                        value=FALSE
                                                        
                                         ),
                                         materialSwitch(inputId = "hide_non_total_columns_adv",
                                                        label = strong("Hide non Total columns"), 
                                                        value=FALSE
                                                        
                                         )
                                         
                                       ),
                                       
                                       mainPanel(
                                         tableOutput("table2") 
                                       )
                                     ),
                            )
                            #TODO: Can update with html files generated from the topline templates or remove these
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
  output$selected_var <- renderUI({ 
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
  
  #Using renderUI of htmlTable from toplines keeps formatting of labels vs. using renderTable
  output$table <- renderUI(
    
    
    if (!is.null(input$var_question_reg) & !is.null(input$var_demo_reg)){
      HTML(paste("<h5>This crosstab represents the percentage of people who fall into the column category that answered the row response to the selected question(s).</h5>"))
      htmlTable(create_crosstab_app(input$var_question_reg, input$var_demo_reg,input$add_subtotal, input$hide_non_total_rows),align="c")
    }
    else{
      HTML(paste("<h5>Welcome to the custom crosstab explorer for the survey. This space will be empty until at least one value for each dropdown is selected on the left panel.</h5>"))
    }
  )
  
  
  #Using renderUI of htmlTable from toplines keeps formatting of labels vs. using renderTable
  output$table2 <- renderUI(
    
    if (!is.null(input$var_demo_adv) & !is.null(input$var_demo_adv2) & !is.null(input$var_demo_adv3)){
      HTML(paste("<h5>This crosstab represents the percentage of people who fall into the column category that answered the row response to the selected question(s).</h5>"))
      htmlTable(create_crosstab_app_adv(input$var_demo_adv, input$var_demo_adv2, input$var_demo_adv3,input$add_subtotal_adv,input$hide_non_total_rows_adv, input$hide_non_total_columns_adv),align="c")
    }
    else{
      HTML(paste("<h5>Welcome to the custom crosstab explorer for the survey. This space will be empty until at least one value for each dropdown is selected on the left panel.</h5>"))
    }
  )
  
}

shinyApp(ui = ui, server = server)