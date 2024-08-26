# Importing libraries
library(datasets) # Contains the Iris data set
library(caret) # Package for machine learning algorithms / CARET stands for Classification And REgression Training
library(dplyr)

# Importing the Iris data set
data("ToothGrowth")

# Check to see if there are missing data?
sum(is.na(ToothGrowth))

# To achieve reproducible model; set the random seed number
set.seed(100)

# Performs stratified random split of the data set
TrainingIndex <- createDataPartition(ToothGrowth$supp, p=0.8, list = FALSE)
TrainingSet <- ToothGrowth[TrainingIndex,] # Training Set
TestingSet <- ToothGrowth[-TrainingIndex,] # Test Set

# Visualization
average <- ToothGrowth %>%
  group_by(dose, supp) %>%
  summarise(mean_len = mean(len, na.rm = TRUE)) %>%
  ungroup()

ggplot(average, aes(x = dose, y = mean_len, fill = supp)) + 
  geom_col(position="dodge") +
  labs(title="Average Length by Dose and Supplement", x = "Dose", y = "Average Length (mm)", fill = "Supplement") +
  #geom_point(data=TrainingSet, aes(dose, len), color="blue") +
  theme_minimal()



###############################
# SVM model (polynomial kernel)

# Build Training model
Model <- train(supp ~ ., data = TrainingSet,
               method = "svmPoly",
               na.action = na.omit,
               preProcess=c("scale","center"),
               trControl= trainControl(method="none"),
               tuneGrid = data.frame(degree=1,scale=1,C=1)
)

# Build CV model
Model.cv <- train(supp~ ., data = TrainingSet,
                  method = "svmPoly",
                  na.action = na.omit,
                  preProcess=c("scale","center"),
                  trControl= trainControl(method="cv", number=4),
                  tuneGrid = data.frame(degree=1,scale=1,C=1)
)


# Apply model for prediction
Model.training <-predict(Model, TrainingSet) # Apply model to make prediction on Training set
Model.testing <-predict(Model, TestingSet) # Apply model to make prediction on Testing set
Model.cv <-predict(Model.cv, TrainingSet) # Perform cross-validation

# Model performance (Displays confusion matrix and statistics)
Model.training.confusion <-confusionMatrix(Model.training, TrainingSet$supp)
Model.testing.confusion <-confusionMatrix(Model.testing, TestingSet$supp)
Model.cv.confusion <-confusionMatrix(Model.cv, TrainingSet$supp)

print(Model.training.confusion)
print(Model.testing.confusion)
print(Model.cv.confusion)

# Feature importance
Importance <- varImp(Model)
plot(Importance)
plot(Importance, col = "red")
