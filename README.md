# Regularization Techniques in Regression Modeling: Ridge, Lasso and Elastic Net

This project analyses the aggregate **production function of the U.S. manufacturing sector** using linear regression and regularization methods.  
Starting from a Cobb–Douglas specification, we estimate a model for **gross production** and compare ordinary least squares (OLS) with **Ridge**, **Lasso** and **Elastic Net** regression. :contentReference[oaicite:0]{index=0}

---

## 1. Objective of the analysis

The main goal is to estimate a linear regression model for **gross production (Y)** and to study how different regularization techniques behave in the presence of **multicollinearity** among inputs.

We consider the following production function:

- **Dependent variable**
  - \( Y \): gross production of the manufacturing sector

- **Regressors**
  - \( K \): capital  
  - \( L \): labor  
  - \( E \): energy  
  - \( M \): other intermediate materials :contentReference[oaicite:1]{index=1}  

The underlying theoretical model is a **Cobb–Douglas production function**, which after log-transformation becomes linear in the parameters:

\[
\log(Y) = \beta_1 \log(K) + \beta_2 \log(L) + \beta_3 \log(E) + \beta_4 \log(M) + \varepsilon
\]

Because of this structure, all regressors must be retained in the final model, even when some coefficients are not individually significant. :contentReference[oaicite:2]{index=2}

---

## 2. Data

The dataset `4_manuf.xlsx` contains observations for the U.S. manufacturing sector: :contentReference[oaicite:3]{index=3}  

- `y` – gross production (Y)  
- `k` – capital (K)  
- `l` – labor (L)  
- `e` – energy (E)  
- `m` – other intermediate materials (M)  

Preliminary descriptive statistics and correlation analysis show that:

- All input variables are **strongly positively correlated**;
- This implies a clear presence of **multicollinearity**, which motivates the use of regularization techniques. :contentReference[oaicite:4]{index=4}  

---

## 3. Baseline OLS models

### 3.1 Initial linear model

We first estimate a standard multiple linear regression:

\[
Y = \beta_0 + \beta_1 K + \beta_2 L + \beta_3 E + \beta_4 M + \varepsilon
\]

Key findings:   

- The **F-test** has a very small p-value (\(p \approx 3.24 \times 10^{-13}\)), so at least one regressor is significant.
- Marginal t-tests indicate that only **M** is clearly significant in this specification.
- The coefficient of determination \(R^2\) is very high, partially due to multicollinearity.
- Residual plots show high dispersion; formal tests are needed to assess heteroscedasticity.

### 3.2 Heteroscedasticity checks

We apply **Breusch–Pagan** and **White** tests under different transformations of the model:   

1. **Original linear model**  
2. **Logarithmic transformation of the dependent variable** (\(\log Y\))  
3. **Model divided by fitted values**  
4. **Logarithmic transformation of all variables** (\(\log Y, \log K, \log L, \log E, \log M\))

Results:

- For the original model and the log-transformed dependent variable, both BP and White tests **fail to reject homoscedasticity**.
- For the model divided by fitted values, the BP test leads to **rejection of homoscedasticity**.
- For the fully log-transformed model, we again **accept homoscedasticity**, making it a suitable functional form for inference.

Given the Cobb–Douglas motivation and the good diagnostic results, we adopt the **log–log model** as the reference OLS specification.   

---

## 4. Train–test split and cross-validation

To evaluate predictive performance, the dataset is split into: :contentReference[oaicite:8]{index=8}  

- **Training set** (70% of observations)  
- **Test set** (30% of observations)

We define custom functions for:

- **MSE (Mean Squared Error)**
- **RMSE (Root Mean Squared Error)**

Using the OLS model estimated on the training set, we compute MSE and RMSE on both train and test sets and investigate model complexity (number of parameters).  

In addition, we perform **cross-validation** using the `cv.glm` function:

- **Leave-One-Out Cross-Validation (LOOCV)**
- **K-fold Cross-Validation** (e.g. K = 12)

LOOCV yields the smallest estimated prediction error among the CV schemes considered.   

---

## 5. Regularization methods

Because of the strong multicollinearity, we extend the analysis using **Ridge**, **Lasso** and **Elastic Net** regression, implemented with the `glmnet` package.   

### 5.1 Ridge regression

- Design matrix \(X\): all regressors except the intercept.  
- Response vector \(y\): gross production.  
- A grid of \(\lambda\) values is defined on a logarithmic scale.

We estimate Ridge models over the grid and inspect the coefficient paths as \(\lambda\) increases: all coefficients are progressively shrunk toward zero but never exactly zero.  

Using **K-fold CV** and **LOOCV** via `cv.glmnet`, we identify the optimal penalty parameter \(\lambda_{\text{min}}\) that minimises the cross-validated MSE. This \(\lambda\) is then used to fit the final Ridge model.   

### 5.2 Lasso regression

To compare with Ridge we estimate the **Lasso** model (setting \(\alpha = 1\) in `glmnet`).

Main observations:   

- For small values of \(\lambda\), several coefficients are shrunk to exactly zero.
- In particular, the coefficient associated with **energy (E)** is set to zero in the final Lasso model selected by CV.
- We compute the optimal \(\lambda\) with K-fold CV and LOOCV; in this case the best \(\lambda\) is stable across both schemes (around 0.01).

### 5.3 Elastic Net

Elastic Net is estimated for different values of the mixing parameter \(\alpha\):

- \(\alpha = 0.1, 0.3, 0.7, 0.9\)

For each \(\alpha\):   

1. We fit models over the same \(\lambda\) grid.  
2. We perform K-fold cross-validation with `cv.glmnet`.  
3. We extract the best \(\lambda\) and estimate the corresponding Elastic Net model.

The resulting models are compared in terms of:

- coefficient patterns (amount of shrinkage and variable selection),
- sign stability of coefficients across methods,
- cross-validated MSE.

In some Elastic Net specifications the coefficient of **E** changes sign when compared to the full OLS model, which complicates economic interpretation. :contentReference[oaicite:14]{index=14}  

---

## 6. Model comparison and final choice

We summarise the results by collecting:

- cross-validated **MSE** for Lasso, Ridge and each Elastic Net configuration;
- the corresponding coefficient vectors. :contentReference[oaicite:15]{index=15}  

Key conclusions:

- All regularization methods reduce variance and mitigate multicollinearity.
- **Lasso** performs variable selection, setting some coefficients (notably **E**) to zero.
- **Elastic Net** provides flexible compromise between Ridge and Lasso, but in some cases produces sign changes that are hard to reconcile with the Cobb–Douglas interpretation.
- **Ridge regression** yields the **lowest cross-validated MSE** among the models considered, with coefficients that remain close in sign and magnitude to the OLS estimates.

For these reasons, **Ridge regression is selected as the preferred model** for predicting gross production in this setting.   

---

## 7. Repository structure

A recommended repository structure for this project is:

```text
.
├─ R/
│   └─ Ridge_Lasso_ElasticNet.R      # Main R script with OLS, CV, Ridge, Lasso, Elastic Net
│
├─ data/
│   └─ 4_manuf.xlsx                  # Manufacturing production dataset
│
│
├─ .gitignore
├─ LICENSE
└─ README.md
