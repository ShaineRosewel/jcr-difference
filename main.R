your_csv <- "Plots needed for Ranking Project Data applications v005.csv"

library(ggplot2)
library(dplyr)
library(tidyr)

your_output_folder <- "plot_outputs"

output_file_suffix <- substring(substring(your_csv, nchar(your_csv) - 7), 1, 4)
if (!dir.exists(your_output_folder)) dir.create(your_output_folder)

wd <- getwd()
raw <- read.csv(paste0(wd, "/data/", your_csv), skip = 1)
mean_travel_time_ranking_2011 <- readRDS(
  paste0(wd, "/data/mean_travel_time_ranking_2011.rds"))

raw <- raw[5:nrow(raw),]
raw <- raw[-c(4, 8, 12, 16, 20:nrow(raw)), ]

raw[raw == "| A_rk+ |"] <- "ARKPLUS"
raw[raw == "| A_rk0 |"] <- "ARKZERO"

raw[raw == "| A_Rk |"] <- "ARKPLUS"
raw[raw == "| A_0k |"] <- "ARKZERO"

transraw <- as.data.frame(t(raw))

reshapedraw <- transraw[colSums(transraw=="" | is.na(transraw))!=52] %>%
  fill(c(`5`, `9`, `13`, `17`, `21`), .direction = "down")

rename_cols <- function(dat){
  colnames(dat) <- c("APPROACH", "ARKPLUS", "ARKZERO")
  return(dat)
}

bounds <- rbind(rename_cols(reshapedraw[-1, c(1:3)]),
                rename_cols(reshapedraw[-1, c(4:6)]),
                rename_cols(reshapedraw[-1, c(7:9)]),
                rename_cols(reshapedraw[-1, c(10:12)]),
                rename_cols(reshapedraw[-1, c(13:15)])) %>% drop_na()

bounds$ARKPLUS <- as.integer(bounds$ARKPLUS)
bounds$ARKZERO <- as.integer(bounds$ARKZERO)

bounds_clean <- cbind(STATE = rownames(bounds), bounds)
rownames(bounds_clean) <- NULL
# bounds_clean$STATE <- gsub("\\.", " ", gsub("[0-9]", "", bounds_clean$STATE))


mean_travel_time_ranking_2011 <- mean_travel_time_ranking_2011 %>% 
  arrange(theta_k_COPIED)
mean_travel_time_ranking_2011$rhat_k <- 1:51 # overwrite ranks
mean_travel_time_ranking_2011 <- mean_travel_time_ranking_2011 %>% arrange(k)


build_plot <- function(APP){
  dataset <- mean_travel_time_ranking_2011 %>% dplyr::select(
    rhat_k,iso, k, theta_k) 
  colnames(dataset) <- c("RANK", "ISO", "STATE", "theta_k")
  
  cardplus <- bounds_clean %>% filter(APPROACH == APP) %>% pull(ARKPLUS)
  cardzero <- bounds_clean %>% filter(APPROACH == APP) %>% pull(ARKZERO)
  
  K <- nrow(dataset)
  
  dataset$LB <- cardplus + 1
  dataset$UB <- cardplus + cardzero + 1
  
  dataset <- dataset %>% arrange(desc(theta_k))
  # dataset$order_index <- seq(K, 1, -1)
  
  to_string_seq <- function(x, y){paste(seq(x, y, 1), collapse=',')}
  
  dat_to_plot <- dataset %>% 
    select(c(STATE, ISO, LB, UB, RANK)) %>%
    mutate(string_ranks = mapply(to_string_seq, LB, UB)) %>%
    separate_rows(string_ranks, sep=",") %>%
    select(c(STATE, ISO, RANK, string_ranks))
  
  dat_to_plot$highlight <- ifelse(
    dat_to_plot$RANK == as.numeric(dat_to_plot$string_ranks), "highlight", 
    "normal")
  
  shading_background <- data.frame(
    ymin = seq(0.5, 48.5, by = 6), 
    ymax = seq(3.5, 51.5, by = 6) 
  )
  
  shading_background$ymax[shading_background$ymax > 51.5] <- 51.5 
  
  
  p <- ggplot() +
    geom_rect(data = shading_background, 
              aes(xmin = -Inf, xmax = Inf, ymin = ymin, ymax = ymax), 
              fill = "gray", alpha = 0.3) +
    geom_label(data = dat_to_plot, 
               aes(x = reorder(STATE, RANK),
                   y = as.numeric(string_ranks),
                   label = ISO,
                   color = highlight, 
                   fill = highlight), 
               size = 2.5,
               label.padding = unit(0.1, "lines"), 
               linewidth = NA) +   
    scale_color_manual(values = c("highlight" = "white", 
                                  "normal" = "black")) +
    scale_fill_manual(values = c("highlight" = "gray28", 
                                 "normal" = "transparent")) +
    
    scale_y_continuous(breaks = 1:51, 
                       expand = expansion(mult = c(0.015, 0.015))) +
    labs(title = stringr::str_to_title(APP), x = 'States', y = expression(r[k])) +
    theme_bw() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      axis.line = element_line(colour = "gray"),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    ) +
    guides(color = "none", fill = "none")
  return(p)
}


for (APP in unique(bounds_clean$APPROACH)) {
  ggsave(
    paste0(wd, "/",your_output_folder, "/", 
           tolower(gsub(" ", "_",APP)), "_", output_file_suffix,".png"), 
    plot = build_plot(APP), width = 11, height = 8, dpi = 300)
}