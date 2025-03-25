# Script metadata ---------------------------------------------------------

# Script : Clasificación del sexo de los pinguinos de antártica con base en características morfológicas
# Author: Julia Silge
# Date: 2020-07-28
# Description: Script tomado de https://juliasilge.com/blog/palmer-penguins/ para explorar el set de datos de Palmer Penguins


# Load packages -----------------------------------------------------------

library(tidyverse)
library(palmerpenguins)
library(tidymodels)


# Build models ------------------------------------------------------------

# Prepare data

penguins_df <- penguins %>%
  filter(!is.na(sex)) %>%
  select(-year, -island)

# Splitting our data into training and testing sets

set.seed(123)
penguin_split <- initial_split(penguins_df, strata = sex)
penguin_train <- training(penguin_split)
penguin_test <- testing(penguin_split)

# create bootstrap resamples of the training data, to evaluate our models.

set.seed(123)
penguin_boot <- bootstraps(penguin_train)
penguin_boot

# We'll compare two different models, a logistic regression model and a random forest model. We start by creating the model specifications.

# Logistic regresion 
glm_spec <- logistic_reg() %>%
  set_engine("glm")

glm_spec

# Random Forest
rf_spec <- rand_forest() %>%
  set_mode("classification") %>%
  set_engine("ranger")

rf_spec


# start putting together a tidymodels workflow(), a helper object to help manage modeling pipelines with pieces that fit together like Lego blocks. Notice that there is no model yet: Model: None.

penguin_wf <- workflow() %>%
  add_formula(sex ~ .)

penguin_wf

# Now we can add a model, and the fit to each of the resamples. First, we can fit the logistic regression model.

glm_rs <- penguin_wf %>%
  add_model(glm_spec) %>%
  fit_resamples(
    resamples = penguin_boot,
    control = control_resamples(save_pred = TRUE)
  )

glm_rs

# fit the random forest model.

rf_rs <- penguin_wf %>%
  add_model(rf_spec) %>%
  fit_resamples(
    resamples = penguin_boot,
    control = control_resamples(save_pred = TRUE)
  )

rf_rs


# Evaluate the model ------------------------------------------------------

collect_metrics(rf_rs)

collect_metrics(glm_rs)

glm_rs %>%
  conf_mat_resampled()

glm_rs %>%
  collect_predictions() %>%
  group_by(id) %>%
  roc_curve(sex, .pred_female) %>%
  ggplot(aes(1 - specificity, sensitivity, color = id)) +
  geom_abline(lty = 2, color = "gray80", size = 1.5) +
  geom_path(show.legend = FALSE, alpha = 0.6, size = 1.2) +
  coord_equal()

# Let’s fit one more time to the training data and evaluate on the testing data using the function last_fit().

penguin_final <- penguin_wf %>%
  add_model(glm_spec) %>%
  last_fit(penguin_split)

penguin_final

collect_metrics(penguin_final)

collect_predictions(penguin_final) %>%
  conf_mat(sex, .pred_class)

penguin_final$.workflow[[1]] %>%
  tidy(exponentiate = TRUE)

# The largest odds ratio is for bill depth, with the second largest for bill length. An increase of 1 mm in bill depth corresponds to almost 4x higher odds of being male. The characteristics of a penguin’s bill must be associated with their sex.

# We don’t have strong evidence that flipper length is different between male and female penguins, controlling for the other measures; maybe we should explore that by changing that first plot!

penguins %>%
  filter(!is.na(sex)) %>%
  ggplot(aes(bill_depth_mm, bill_length_mm, color = sex, size = body_mass_g)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~species)

# the male and female penguins are much more separated now.
