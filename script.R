library(readr)
data <- read_delim("data.csv", delim = ";", 
                   escape_double = FALSE, trim_ws = TRUE)
View(data)

# we'll rename one column:
names(data)[names(data) == 'count turtles with [strategy = ""H""]'] = "countH"

# Correlation Matrix:
cor(data)

# correlation between the individual variables:
cor(data$`initial-H`, data$countH)
cor(data$`retention-strength`, data$countH)
cor(data$`inflow-rate`, data$countH)
cor(data$N, data$countH)
cor(data$N, data$`retention-strength`)
cor(data$`initial-H`, data$`inflow-rate`)
cor(data$N, data$`initial-H`)
cor(data$`initial-H`, data$`retention-strength`)
cor(data$`inflow-rate`, data$`retention-strength`)


# Linear Regression:
model <- lm(countH ~ `initial-H` + `inflow-rate` + N + `retention-strength`, 
            data = data)
summary(model)

# Boxplots:
boxplot(countH ~ `initial-H`, data = data)
boxplot(countH ~ `inflow-rate`, data = data)
boxplot(countH ~ N, data = data)
boxplot(countH ~ `retention-strength`, data = data)

