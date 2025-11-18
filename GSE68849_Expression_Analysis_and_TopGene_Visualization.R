

# Step 1: Installing the required packages
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("GEOquery")
install.packages("dplyr")
install.packages("ggplot2")



# Step 2: Loading the  packages
library(GEOquery)
library(dplyr)
library(ggplot2)


# Step 3: Fetching the  dataset from NCBI GEO database
gset <- getGEO("GSE68849", GSEMatrix = TRUE)[[1]]


# Step 4: Extracting the Gene expression data
expr_data <- exprs(gset)


# Step 5: Extract gene symbols from feature data
feature_data <- fData(gset) %>% select(Symbol)


# Step 6: Combine gene symbols with expression data
expr_df <- data.frame(Gene = feature_data$Symbol, expr_data)


# Step 7: Clean gene symbols (remove blanks, keep first if multiple)
expr_df <- expr_df %>%
  filter(Gene != "" & !is.na(Gene)) %>%
  mutate(Gene = sub(" /// .*", "", Gene))


# Step 8: Calculate the  average expression per gene
expr_df <- expr_df %>%
  mutate(avg_expr = rowMeans(select(., -Gene), na.rm = TRUE))


# Step 9: Filter for highly expressed genes
high_expr <- expr_df %>%
  filter(avg_expr > 8) %>%
  arrange(desc(avg_expr))


# Step 10: Selecting the  top 10 genes
top10 <- head(high_expr, 10)


# Step 11: Printing the  top 10
print(top10)


# Step 12: Visualize top genes
ggplot(top10, aes(x = reorder(Gene, avg_expr), y = avg_expr)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Highly Expressed Genes in GSE68849",
    x = "Gene Symbol",
    y = "Average Expression"
  ) +
  theme_minimal()
