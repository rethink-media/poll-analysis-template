# Poll Analysis Template
A set of templates that can be used to recode, weight, and produce topline and crosstab tables of Qualtrics polling sav files. These were initially created for use on ReThink Media polls.


## Assumptions about Poll
While the templates provide a starting block that can easily be modified, we wanted to outline the requirements/assumptions we had for our polls so that you know what the templates were originally set up to work with:

* Data is downloaded from Qualtrics as an SPSS sav data file with raw data, variable, and value labels
* All question variables start with Q
* All demographic variables start with D_
* Questions that we refer to as "matrix-style" that offer the same prompt with a different ending all start with the same Q#_ like Q9_1, Q9_2, Q9_3

Since our assumption is the data comes in as an SPSS data file, we assume it is labelled data. We make the following additional assumptions about the coding of the value/label pairs for different labelled variables.

Value label assumptions. Note that when value labels differ from the below, the recoding functions may not work correctly. Update these functions in the Import_template.Rmd with any modifications to your labels:

* RegVote
	* 1 = Yes
	* 2 = No

* D_Age
	* 1 = 18-24
	* 2 = 25-29
	* 3 = 30-34
	* 4 = 35-39
	* 5 = 40-44
	* 6 = 45-49
	* 7 = 50-54
	* 8 = 55-59
	* 9 = 60-64
	* 10 = 65-69
	* 11 = 70-74
	* 12 = 75+

* D_Religion
	* 1 = Evangelical/Born-again Protestant
	* 2 = Mainline Protestant
	* 3 = Catholic
	* 4 = Mormon/LDS
	* 5 = Other Christian
	* 6 = Jewish
	* 7 = Muslim
	* 8 = Hindu
	* 9 = Buddhist
	* 10 = Other non-Christian
	* 11 = None/Nothing in particular
	* 12 = Agnostic
	* 13 = Atheist

* D_PID
	* 1 = Strong Democrat
	* 2 = Not too strong Democrat
	* 3 = Independent, leaning towards Democrats
	* 4 = Independent, no lean / Other
	* 5 = Independent, leaning towards Republicans
	* 6 = Not too strong Republican
	* 7 = Strong Republican

* D_Race
	* 1 = Hispanic/Latinx (of any race)
	* 2 = Middle Eastern/North African (of any race)
	* 3 = Black/African American
	* 4 = White (not Hispanic/Latinx or Middle Eastern/North African)
	* 5 = Asian American/Pacific Islander
	* 6 = Native American/Indigenous (Alaska or Hawaii Native, etc.)
	* 7 = Other/Mixed Race

* D_Gender
	* 1 = Male
	* 2 = Female
	* 3 = Non-binary/Non-conforming
	
* D_Ideo_1 : "On a scale of one (1) to seven (7), how would you rate your political ideology?One (1) is very liberal/left. Four (4) is moderate/centrist. Seven (7) is very conservative/right. - Rate"

* Emotion Questions: 
	* 1 = Hopeful
	* 2 = Inspired
	* 3= Confident
	* 4 = Worried
	* 5 = Angry
	* 6 = Hopeless
	* 7 = Overwhelmed
	* 8 = Skeptical
	* 9 = Other (please specify):
	* 10 = Motivated
	
	
Variable label assumptions:

* Questions such as "Below is a list of names of people/groups. Please indicate your opinion of each, and how strongly you feel that way. If you have never heard of one, or have heard of them but have no opinion, just indicate that." that ask about a variety of people/groups use a " - " separator in between the prompt and the person/groups such as "Below is a list of names of people/groups. Please indicate your opinion of each, and how strongly you feel that way. If you have never heard of one, or have heard of them but have no opinion, just indicate that. - Joe Biden". All of the variable names will start with the same Q#_ such as Q9_1 and Q9_2


We have provided a sample Qualtrics data file that follows these assumptions and is used in the following templates as an example.
[`Test+Poll+for+R+Code_July+19,+2021_17.34.sav`](https://github.com/rethink-media/poll-analysis-template/blob/main/Test%2BPoll%2Bfor%2BR%2BCode_July%2B19%2C%2B2021_17.34.sav)

## Description of Template Types

### Import_template.Rmd

Start with [`Import_template.Rmd`](https://github.com/rethink-media/poll-analysis-template/blob/main/Import_template.Rmd) first before any other files to produce a new data file in sav format that is recoded, weighted, and contains audience labels & scores.

Then, review any code with comments including "TODO" in the notebook. This may advise removing some code, adding some poll specific information, uncommenting or commenting certain sections, etc.

To confirm the recoding did what you expected, I recommend setting a new dataframe variable such as temp to recode_all(df) and outputing some cro tables in the console to check the counts of cro(df$D_Race, temp$D_Race) before/after the recoding.

Running this will output a raw poll sav file that's weighted and categorized by audience.


### Basic_topline_crosstab_template.Rmd

After you've updated and run [`Import_template.Rmd`](https://github.com/rethink-media/poll-analysis-template/blob/main/Import_template.Rmd) for your new poll, it should have output a raw poll sav file. This can be used to generate a new toplines file. Specify the path to this raw poll output file in this notebook and then look for all of the TODO in the notebook for what code to update for your new poll. These may be things like column names, subtotals, styling, etc ...

This file specifically will produce a standard/basic toplines and crosstabs.

If you know it now, update the markdown text at the top of the notebook, with the following information specific to this poll:

* Title
* The date range the poll was conducted
* Number of Adults Desired for Poll
* Confidence Interval

Then, review any code with comments including "TODO" in the notebook. This may advise removing some code, adding some poll specific information, uncommenting or commenting certain sections, etc.


### Audience_topline_crosstab_template.Rmd

After you've updated and run [`Import_template.Rmd`](https://github.com/rethink-media/poll-analysis-template/blob/main/Import_template.Rmd) for your new poll, it should have output a raw poll sav file. If you ran an audience analysis in the [`Import_template.Rmd`] notebook, the sav file will contain an audience variable categorizing each respondent as "Base", "Persuadable" or "Opposition". This can be used to generate a new toplines file. Specify the path to this raw poll output file in this notebook and then look for all of the TODO in the notebook for what code to update for your new poll. These may be things like column names, subtotals, styling, etc ...

This file specifically will produce a toplines and crosstabs that contains the audiences. Notably, the toplines will contain crosstabs of audiences with the different questions whereas the standard toplines just contains percent/counts of questions of the total respondents.

If you know it now, update the markdown text at the top of the notebook, with the following information specific to this poll:

* Title
* The date range the poll was conducted
* Number of Adults Desired for Poll
* Confidence Interval

Then, review any code with comments including "TODO" in the notebook. This may advise removing some code, adding some poll specific information, uncommenting or commenting certain sections, etc.

### visualizations_template.Rmd

After you've updated and run [`Import_template.Rmd`](https://github.com/rethink-media/poll-analysis-template/blob/main/Import_template.Rmd) for your new poll, it should have output a raw poll sav file with audiences in it. If the poll contains questions asking respondents about their emotional responses to messages/statements (in the format detailed above in the "Assumptions" section), this notebook can be used to generate a set of bar charts to display the results for emotions questions, grouped by Audience category (Base, Persuadable, Opposition). Open up this template and edit any code with TODO in the comments above.


### crosstab_app_functions_template.R

This should read in the raw poll file output from running [`Import_template.Rmd`](https://github.com/rethink-media/poll-analysis-template/blob/main/Import_template.Rmd). Go through the file and update any code with TODO. This may advise removing some code, adding some poll specific information, uncommenting or commenting certain sections, etc.

### app_template.R

Open this file and update any code with TODO. These are mainly styling/editing updates specific to this poll. Note this file will need to be saved as app.R for the code to run and that all data files used for the app must be in the same folder as this and the prior R crosstab app file.


## How to get started & Things to Know

### Working with Labelled Data in R

* Terminology:
	* variable is the column name like "D_Race" or "Q20"
	* value is the data value like 1,2,3,4,etc...
	* value label is the text label for the value like (1 = Male, 2= Female, 3 = Nonbinary, etc)
	* variable label is the text label for the variable like "What is your gender?" or "Please describe the words, phrases, or images that come to mind for you when you see the term: terrorist attack."
* [`Haven`](https://cran.r-project.org/web/packages/haven/haven.pdf) was recommended for reading in & saving off .sav files which contain labelled spss data. This means that the data is stored as variable names for columns like Q20 and the values in the rows are 1,2,3,4 etc. Helper functions can be used to access matching labels for the values and the variable names to identify the full question text and answers.
* Once the data is read in, you can use labelled data functions to get or set variable & value labels. [`expss`](https://cran.r-project.org/web/packages/expss/expss.pdf) and [`sjlabelled`](https://cran.r-project.org/web/packages/sjlabelled/sjlabelled.pdf) are both useful for this but have slightly different functions you might want to use.
	* var_lab & val_lab are useful functions from expss that can be used to get/set labels.
	* get_label and get_labels are useful functions from sjlabelled to get/set labels but can be passed additional arguments like values=TRUE or FALSE to include or not the numbers in the data the values correspond to. 

### Recoding

* [`expss`](https://cran.r-project.org/web/packages/expss/expss.pdf) has a recode functionality that works well. Here are some nuances:
	* Values for the recoding need to start at 1 and not contain any gaps. i.e. If you recode 1 to 4, you need to recode something else to 1 so there's always a 1. And you can't have any gaps in the resulting values. See the recode PID_ind for an example of this.
	* Recommend applying the haven labelled after recoding to get the labels back
	

### Weighting

* [`anesrake`](https://cran.r-project.org/web/packages/anesrake/anesrake.pdf) has an anesrake weighting functionality that works well. Here are some nuances:
	* For variables you want to weight, you need to do the following:
		* Create a vector with the weights. These weights need to be in the order of the value labels in the data. Here's an example: D_Gender = c(Male=.475, Female=.52,Nonbinary=.005)
		* Then you need to provide names to this variable storing the weights in that same order. Here's an example: names(D_Gender)=c("Male","Female","Non-binary/Non-conforming")
		* If you are re-weighting many variables at once, you'll also need to put these weight vector variables in a list and name it with the variable names from the dataframe.
		* Refer to the run_raked_weighting function and comments in the [`Import_template.Rmd`](https://github.com/rethink-media/poll-analysis-template/blob/main/Import_template.Rmd) for more help
		

### Audience Labelling
* The audience scoring and labeling code is in [`Import_template.Rmd`](https://github.com/rethink-media/poll-analysis-template/blob/main/Import_template.Rmd)
* It expects you to provide a few questions, values for the responses to these questions, and cutoff values to use when looking at the total scores creating by weighting the different responses to the provided questions. 3 audience categories will be created: Base, Opposition, and Persuadable.
* Look at the comments within [`Import_template.Rmd`](https://github.com/rethink-media/poll-analysis-template/blob/main/Import_template.Rmd) for more information on this.

### Using expss for crosstabs & table generation

* [`expss`](https://cran.r-project.org/web/packages/expss/expss.pdf) has two main types of table generation functionality. Both were useful in generating tables for the surveys.
	* Custom tables using magrittr/dplyr piping
		* Refer to the toplines tables created with this in the [`Import_template.Rmd`](https://github.com/rethink-media/poll-analysis-template/blob/main/Import_template.Rmd). You can search for "tab_cells" in this notebook which is a function used in creation for this.
		* Some of these custom table piping functions were difficult for me to find documentation for so I will provide it here. I also recommend cross-referencing the guidance below with the expss documentation:
			* tab_total_row_position : this can be used to set the position of the row in the table that contains total counts or percents. Providing this the parameter "none" results in the total row not showing. This was useful for percentage tables where the total would always be 100% and thus wasn't useful to show
			* tab_weight : this takes in the dataframe weight column to weight the values in the table appropriately
			* tab_stat_cpct or tab_stat_cases can be fed the following parameters (total(label="Total"),label = "Percent"). Parameters for labels that will display on the table for the Total count/percent and the column header of counts/percents
			* tab_subtotal_cells(1:2,3:4,prefix="Total: ",position = "above",add=FALSE). Function for generating subtotals. Note the 1:2, 3:4 only works is the values are still 1-4. If the values have been removed, you can list a vector of the string names of these columns like this: (df[[i]],c("Strongly support","Somewhat support"),c("Somewhat oppose","Strongly oppose"),prefix="Total: ",position = "bottom"). Search for "subtotal" in [`Audience_topline_crosstab_template.Rmd`](https://github.com/rethink-media/poll-analysis-template/blob/main/Audience_topline_crosstab_template.Rmd). And refer to the expss documentation.
			* If you'd like to remove or suppress labels from showing in the tables, you can set the variable you want to be suppressed equal to "|".
				* For example, temp = apply_labels(df, D_Gender = "|") will result in the gender variable not containing any label in a table. See an example of this in [`crosstab_app_functions_template.R`](https://github.com/rethink-media/poll-analysis-template/blob/main/crosstab_app_functions_template.R)
			
	* Cro tables
		* Refer to the crosstab tables created with this in the [`Basic_topline_crosstab_template.Rmd`](https://github.com/rethink-media/poll-analysis-template/blob/main/Basic_topline_crosstab_template.Rmd). You can search for "tab_cells" in this notebook which is a function used in creation for this.
		* Some useful functions/nuances to cross-reference with the documentation:
			* The first two parameters to this first can both be lists of columns to crosstab or single columns to crosstab.
			* If any of the columns contain a subtotal, add this as a column or item in a column list parameter. See this example: cro_cpct(subtotal(df[[column]],1:2,3:4,prefix="Total: ",position = "bottom"), crosstab_qs, weight=weights_compressed_vec, total_row_position = "none") Note crosstab_qs is a list of columns. 
				* Search for subtotal in [`Audience_topline_crosstab_template.Rmd`](https://github.com/rethink-media/poll-analysis-template/blob/main/Audience_topline_crosstab_template.Rmd) for examples of this being used in table generation. And refer to the expss documentation.

### Formatting tables with htmltable

* [`htmlTable`](https://cran.r-project.org/web/packages/htmlTable/htmlTable.pdf) is a useful package for turning the results of the expss table functions into htmltables that display nicely in html markdown.
* Some useful things to look at with this package:
	* css.cell - A parameter input to htmlTable to override the style of the table with the css contained in this parameter. css.cell can take a matrix that is the size of the number of rows by number of columns. Or it can take a vector of length of the number of columns. If it takes a vector, each column refers to the styling for the full column in the table. Note some styling can be adjusted with the [`style.css`](https://github.com/rethink-media/poll-analysis-template/blob/main/style.css) but a lot of the table styling from htmlTable will override what's in that file. You can specify where you want certain styling to take place and what style to use there by specificing locations in the css.cell matrix. Refer to the code and [`this Stackoverflow`](https://stackoverflow.com/questions/31323885/how-to-color-specific-cells-in-a-data-frame-table-in-r) for examples. Search for "css.cell" in the [`Basic_topline_crosstab_template.Rmd`](https://github.com/rethink-media/poll-analysis-template/blob/main/Basic_topline_crosstab_template.Rmd) for examples of how it was used to apply selective bolding to tables with subtotal rows.
	* align - A parameter input to htmlTable to adjust the center/right/left alignment of values in the table columns. Also, refer to this [`How-to use htmltable vignette`](https://cran.r-project.org/web/packages/htmlTable/vignettes/general.html) for examples. This can take a single letter to set the alignment for all columns or a string of length of the number of columns where each letter refers to an alignment of a column.
	* addHtmlTableStyle - useful function to apply additional table styles. This was useful for overriding the default table styling to bold row headings. By providing font-weight normal to the css.rgroup : addHtmlTableStyle(x=topline_table,css.rgroup = c("font-weight:normal"))

### Visualizing data with ggplot & quanteda
* [`ggplot2`](https://ggplot2.tidyverse.org/) was used to visualize the grouped bar chart counts of emotions by audiences. Documentation online is pretty good for ggplot, including Stackoverflow posts.
* [`quanteda`](https://quanteda.io/) was used to tokenize, clean, and visualize words from the open response questions of a survey.

### Excel & R Functionality
* [`openxlsx`](https://cran.r-project.org/web/packages/openxlsx/openxlsx.pdf) was useful in outputing the crosstab expss tables into XL. Some particularly useful functions & parameters were:
	* createStyle with halign set to center : horizontally aligning with center in the XL sheet
	* wrapText : wrapping the text in XL
	* mergeCells : to merge cells into bigger cells


### R Shiny
* To deploy R Shiny apps using shinyapps.io:
	1. Install RSConnect by running  `install.packages('rsconnect')` in your console
	2. Authorize the account by running `library(rsconnect)` and then `rsconnect::setAccountInfo(name='<Your Account Name>',
			  token='<Your Token Number>',
			  secret='<Your SECRET Number>')` in your console. Note to get updated tokens & secrets, you can go to the [Tokens page under the menu](https://www.shinyapps.io/admin/#/tokens)
	3. Deploy your app by running `rsconnect::deployApp('path/to/your/app')` in your console. You can use getwd() to get the current path and then update the 'path/to/your/app' to point from your current path to the directory the app.R is stored.
* For more information, check out these instructions https://docs.rstudio.com/shinyapps.io/


