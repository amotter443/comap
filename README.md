# comap
Using clustering and unsupervised learning to analyze sentiment of online product reviews



About the Competition
------------------------
 The Consortium for Mathematics and Its Applications (COMAP) Mathematical Contest in Modeling is an international math modeling competition designed to test students’ prowess within specific dimensions of mathematics in a constrained time frame. Each team is limited to 3 members, and these members are given from Thursday evening to Monday afternoon to select, digest, analyze, model, report on, and submit findings for a specific problem. 

Problem C, data insights, is an area I competed in twice in university. In the 2019 competition, creating data-driven policy and solutions to respond to the opioid crisis, we placed Honorable Mention in the top 20% of entrants, meaning "The team's report contained elements that were judged to contain above average progress in modeling and problem solving." Despite this initial success, I wanted to attempt this competition in 2020 again to see if a year's worth of development experience would improve the team outcome. 

The 2020 Problem C provided customer review data across multiple products (pacifiers, microwaves, and hairdryers), and asked to create a data-driven product design and performance monitoring strategy for these three items. Without including external datasets, the ideal product in each category was to be created and key terms that indicate whether that item was succeeding or failing should be identified for monitoring in customer feedback. In our team, each of the team members 'specialized' with a single dataset, in my case the pacifier one. All of the scripts in this repo are for the pacifier dataset, but a similar logic was applied for the microwaves/hairdryers and their requisite datasets are also attached. The cleaning script for example gives a comprehensive understanding of the effort required to extract meaningful insights from this unstructured text data and to build usable models from the reviews.

 
Who is this project for?
------------------------
- Collegiate-level data science students looking to benchmark their skillset
- Professionals working primarily in a customer review/NLP-based environment looking for further hone their skills with real data
- Developers early in their careers looking for greater exposure to clustering/unsupervised problems
 
 
Data Dictionary
------------------------
 The data dictionary for each dataset varies based on the unique insights derived for each of the three datasets. A general data dictionary across datasets is provided, with specific ones for each of the pacifier, microwave, and hairdryer datasets respectfully. For the full data dictionary, please consult pages 21-23 of `2019330.pdf`

 
Usage
------------------------
Note: 
The included files focus on the data pre-processing and primary sentiment analysis/clustering modeling of the solution. Some of the other features that were not included were: gradient descent, time & sankey data generation, and several different iterations of ggplot visualization scripts written
- Download the three data files
- Read into R/Python environment, head to get a better understanding of it
- Clean the initial input files using the methodology of the `Report_Cleaning.R` script
- Perform exploratory analysis, time-series analysis, and fallout analysis using ggplot and custom visualizations in Tableau
- Break data into word and sentence level granularities and perform sentiment analysis in `Report_Script.R`
- Use unsupervised clustering methods to better understand relationship between product favorability also in `Report_Script.R`
- Derive data-driven strategy using these insights 
 
 
 
Reflections
------------------------
Working with NLP modeling and unstructured text data brought an increased appreciation for auto-ML solutions and the many advancements within this area of machine learning. Understanding the nuances of customer review data (the bimodal distribution of users loving/hating projects, slang, contractions, etc.) and the many ways that human inputs can break standard modeling. For those interested in exploring the challenges of this space, [this MIT Technology Review](https://www.technologyreview.com/2021/05/20/1025135/ai-large-language-models-bigscience-project/) provides a useful overview of the contemporary language AI landscape.

This project was conducted in a codeathon-style environment, where very little sleep or breaks were taken. With the added benefit of hindsight, unlimited time, and over a year's additional experience, there are understandably many changes I would have made to this project. Rather than harping on the shortcomings of the solution, I found this project to serve better as a skills benchmark as it incorporates several of the key skillsets of data science (data cleaning, creative problem solving, clustering, output interpreting, etc.). 

Additionally, the competition took place at the end of my undergrad and over a year ago, and in the time since my skills have grown significantly. The code exhibits several signs of an earlier-stage developer, including a heavy reliance on pre-built packages, continuous use of functions without an iterative or mapping framework to consolidated repeating behaviors, etc. My personal growth in skillset since then serves as a great reminder of the importance of continuous learning. Despite this personal shortcomings, the team concluded with a rating of Meritorious Winner, representing the top 6% of 7400 worldwide entrants and one of the top 5 US teams. I'm excited to see how continued developmental upskilling leads to similar growth in future competitions.
