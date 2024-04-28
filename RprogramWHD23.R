## LOAD LIBRARY AND DATA
# Load necessary libraries
library(readr)
library(dplyr)
library(ggplot2)
library(corrplot)

# Set the working directory to where your file is located
setwd("/Applications/FILES/STUDY/R PROGRAM")

# Load the data
data <- read_csv("WHData2023.csv")


## UNDERSTAND DATA
# Display the few rows of the dataset
head(data)
tail(data)

# Get basic information about the dataset
str(data)

# Summary statistics
summary(data)

# Display data types of each column
sapply(data, class)


## DATA CLEANING
# Check for missing values
colSums(is.na(data))

# Impute missing values with the mean of their respective columns
data$`Log GDP per capita`[is.na(data$`Log GDP per capita`)] <- mean(data$`Log GDP per capita`, na.rm = TRUE)
data$`Social support`[is.na(data$`Social support`)] <- mean(data$`Social support`, na.rm = TRUE)
data$`Healthy life expectancy at birth`[is.na(data$`Healthy life expectancy at birth`)] <- mean(data$`Healthy life expectancy at birth`, na.rm = TRUE)
data$`Freedom to make life choices`[is.na(data$`Freedom to make life choices`)] <- mean(data$`Freedom to make life choices`, na.rm = TRUE)
data$Generosity[is.na(data$Generosity)] <- mean(data$Generosity, na.rm = TRUE)
data$`Perceptions of corruption`[is.na(data$`Perceptions of corruption`)] <- mean(data$`Perceptions of corruption`, na.rm = TRUE)
data$`Positive affect`[is.na(data$`Positive affect`)] <- mean(data$`Positive affect`, na.rm = TRUE)
data$`Negative affect`[is.na(data$`Negative affect`)] <- mean(data$`Negative affect`, na.rm = TRUE)

# Check if missing values are resolved
colSums(is.na(data))

# Remove duplicate rows
data <- unique(data)

# Define numerical columns
num_cols <- c('Life Ladder', 'Log GDP per capita', 'Social support', 
              'Healthy life expectancy at birth', 'Freedom to make life choices', 
              'Generosity', 'Perceptions of corruption', 'Positive affect', 'Negative affect')
# Select only numeric columns
num_data <- data[, sapply(data, is.numeric)]


# Create boxplots for each numerical column to check Outliers
par(mfrow=c(3, 3))
for (col in num_cols) {
  boxplot(data[[col]], main=col, col="lightblue", border="black")
}

# Function to replace outliers with median
replace_outliers <- function(x) {
  q1 <- quantile(x, 0.25)
  q3 <- quantile(x, 0.75)
  iqr <- q3 - q1
  lower_bound <- q1 - 1.5 * iqr
  upper_bound <- q3 + 1.5 * iqr
  x[x < lower_bound] <- median(x, na.rm = TRUE)
  x[x > upper_bound] <- median(x, na.rm = TRUE)
  return(x)
}

# Apply outlier replacement to each numerical column
for (col in num_cols) {
  data[[col]] <- replace_outliers(data[[col]])
}

# Function to calculate trimmed mean
trimmed_mean <- function(x, trim_percent) {
  lower_trim <- quantile(x, trim_percent / 2)
  upper_trim <- quantile(x, 1 - trim_percent / 2)
  x_trimmed <- x[x >= lower_trim & x <= upper_trim]
  return(mean(x_trimmed))
}

# Apply trimmed mean to each numerical column
trim_percent <- 0.05  # You can adjust the trim percentage as needed
for (col in num_cols) {
  data[[col]] <- sapply(data[[col]], function(x) ifelse(x < quantile(x, trim_percent) | x > quantile(x, 1 - trim_percent), trimmed_mean(x, trim_percent), x))
}

# Check boxplots after using increased trim percentage
par(mfrow=c(3, 3))
for (col in num_cols) {
  boxplot(data[[col]], main=col, col="lightblue", border="black")
}


## DATA VISUALIZATION 
# Create histograms for all numerical columns
par(mfrow=c(3, 3))  # Set up a 3x3 grid for plots
for (col in num_cols) {
  hist(data[[col]], main=col, col="lightblue", border="black", xlab=col)
}

# Define the main variable and other variables for comparison
main_variable <- "Life Ladder"
other_variables <- c("Log GDP per capita", "Social support", "Healthy life expectancy at birth", 
                     "Freedom to make life choices", "Generosity", "Perceptions of corruption", 
                     "Positive affect", "Negative affect")

# Create scatter plots comparing the main variable with other variables
par(mfrow=c(3, 3))  # Set up a 3x3 grid for plots
for (var in other_variables) {
  plot(data[[main_variable]], data[[var]], 
       main=paste("Scatter plot of", main_variable, "vs", var), 
       xlab=main_variable, ylab=var, col="red")
}


## CHECK MULTICOLLINEARITY
# Load necessary library
if (!requireNamespace("car", quietly = TRUE)) {
  install.packages("car")
}
library(car)

# Replace spaces with underscores in column names
names(num_data) <- gsub("\\s+", "_", names(num_data), perl = TRUE)

# Compute VIF for each variable
vif_values <- sapply(names(num_data), function(x) {
  predictors <- setdiff(names(num_data), x)
  formula <- paste("Life_Ladder", "~", paste(predictors, collapse = "+"))
  lm_result <- lm(formula, data = num_data)
  car::vif(lm_result)
})

# Print VIF values
print(vif_values)

# Calculate the correlation matrix
correlation_matrix <- cor(num_data)

# Plot heatmap
heatmap(correlation_matrix, 
        col = colorRampPalette(c("blue", "white", "red"))(100),
        symm = TRUE,
        margins = c(5, 5))

# Print correlation matrix
print(correlation_matrix)

# View column names
colnames(data)

# Exclude the "Year" column
numeric_data <- data[, sapply(data, is.numeric)]
numeric_data <- numeric_data[, !colnames(numeric_data) %in% c("year")]

# Calculate average scores
avg_scores <- colMeans(numeric_data)

# Create bar plot of average scores
barplot(avg_scores, col = "skyblue", main = "Average Scores (Excluding Year)", ylab = "Average Score")

# Load necessary library for plotting
library(ggplot2)

# Scatter plot
scatter_plot <- ggplot(data, aes(x = `Log GDP per capita`, y = `Life Ladder`)) +
  geom_point() +
  labs(title = "Scatter Plot", x = "Log GDP per capita", y = "Life Ladder")

# Bar plot
bar_plot <- ggplot(data, aes(x = `Country name`, y = `Life Ladder`)) +
  geom_bar(stat = "identity") +
  coord_flip() +  # Rotate x-axis labels
  labs(title = "Bar Plot", x = "Country", y = "Life Ladder")

# Line plot
line_plot <- ggplot(data, aes(x = year, y = `Life Ladder`)) +
  geom_line(color = "blue") +
  labs(title = "Line Plot", x = "Year", y = "Life Ladder Score")

# Histogram
histogram <- ggplot(data, aes(x = `Life Ladder`)) +
  geom_histogram(binwidth = 0.5, fill = "lightblue", color = "black") +
  labs(title = "Histogram", x = "Life Ladder", y = "Frequency")

# Box plot
box_plot <- ggplot(data, aes(x = factor(1), y = `Life Ladder`)) +
  geom_boxplot(fill = "lightblue", color = "black") +
  labs(title = "Box Plot", x = "", y = "Life Ladder")

# Print the plots
print(scatter_plot)
print(bar_plot)
print(line_plot)
print(histogram)
print(box_plot)


