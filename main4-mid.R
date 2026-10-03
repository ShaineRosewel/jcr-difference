your_csv <- "Plots needed for Ranking Project Data applications v008-b.csv"

library(ggplot2)
library(dplyr)
library(tidyr)


suptitle = 'Top 12 States'
APP = 'Bootstrap variance with equal marginal coverage'

# to_rescale <- c(27,24,23,29,27,20,29,23,20,23,25,30) # MID

to_rescale <- c(44,48,40,44,47,51,46,42,49,50,41,45) # TOP
num_elements <- length(to_rescale)


facets <- c(tools::toTitleCase(APP), "Wright's Methodology")

facet_names <- c(
  "proposed_string_ranks" = tools::toTitleCase(APP),
  "wright_string_ranks" = "Wright's Methodology"
)

your_output_folder <- "plot_outputs"

output_file_suffix <- substring(substring(your_csv, nchar(your_csv) - 7), 1, 4)
if (!dir.exists(your_output_folder)) dir.create(your_output_folder)

wd <- getwd()
raw <- read.csv(paste0(wd, "/data/", your_csv), skip = 1)
mean_travel_time_ranking_2011 <- readRDS(
  paste0(wd, "/data/mean_travel_time_ranking_2011.rds"))

states_of_interest <- gsub("\\.", " ",names(raw[1,2:length(names(raw[1,]))]))



raw <- raw[5:nrow(raw),]
# raw <- raw[-c(4, 8, 12, 16, 20:nrow(raw)), ]
raw <- raw[-c(4, 8, 12, 16), ]

raw[raw == "| A_k+ |"] <- "ARKPLUS"
raw[raw == "| A_k0 |"] <- "ARKZERO"

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

# SEQUENCING OF COUNTRIES - ESP WHEN THERE ARE TIES
mean_travel_time_ranking_2011$rhat_k <- c(2,1,4,3,5,6,7,8,9,10,11,12,13,15,14,16,17,18,20,19,23,22,21,24,25,27,26,29,28,30,32,31,34,33,36,37,38,39,40,41,42,43,45,44,46,47,48,49,50,51,52)#1:51 # overwrite ranks

mean_travel_time_ranking_2011 <- mean_travel_time_ranking_2011 %>% filter(k %in% states_of_interest)

mean_travel_time_ranking_2011 <- mean_travel_time_ranking_2011 %>% arrange(k)

dataset <- mean_travel_time_ranking_2011 %>% dplyr::select(
  rhat_k,iso, k, theta_k)
colnames(dataset) <- c("RANK", "ISO", "STATE", "theta_k")

cardplus <- bounds_clean %>% 
  filter(APPROACH == APP) %>%
  pull(ARKPLUS)
cardzero <- bounds_clean %>% 
  filter(APPROACH == APP) %>%
  pull(ARKZERO)

K <- nrow(dataset)

dataset$LB <- cardplus + 1
dataset$UB <- cardplus + cardzero + 1

# ==============================================================================
wright_cardplus <- bounds_clean %>% 
  filter(APPROACH == 'Wright methodology') %>%
  pull(ARKPLUS)
wright_cardzero <- bounds_clean %>% 
  filter(APPROACH == 'Wright methodology') %>%
  pull(ARKZERO)

K <- nrow(dataset)

dataset$wright_LB <- wright_cardplus + 1
dataset$wright_UB <- wright_cardplus + wright_cardzero + 1


# dataset$RK <- c(27, 6, 34, 11, 44, 32, 35, 36, 48, 40, 44, 39, 9, 47, 24, 7, 8, 17, 32, 23, 51, 46, 29, 18, 27, 20, 5, 4, 29, 42, 49, 12, 50, 23, 2, 20, 10, 16, 41, 23, 25, 2, 30, 34, 13, 15, 45, 37, 38, 15, 4)

maxx <- max(to_rescale)
minn <- min(to_rescale)
dataset$RK <- round(((to_rescale - minn)/(maxx - minn) ) * (num_elements - 1) + 1, 0)


to_rescale <- dataset$RANK
maxx <- max(to_rescale)
minn <- min(to_rescale)
dataset$RANK <- round(((to_rescale - minn)/(maxx - minn) ) * (num_elements - 1) + 1, 0)
# ==============================================================================

to_string_seq <- function(x, y){paste(seq(x, y, 1), collapse=',')}


dat_to_plot <- dataset %>% 
  select(c(STATE, ISO, LB, UB, wright_LB,wright_UB, RANK, RK)) 




proposed <- mapply(function(x, y) seq(x,y), dataset$LB, dataset$UB)
wright <- mapply(function(x, y) seq(x,y), dataset$wright_LB, dataset$wright_UB)
dat_to_plot$in_wright <- mapply(function(x, y) setdiff(x,y), wright, proposed)
dat_to_plot$in_proposed <- mapply(function(x, y) setdiff(x,y), proposed, wright)




dat_to_plot <- dat_to_plot %>%
  mutate(proposed_string_ranks = mapply(to_string_seq, LB, UB),
         wright_string_ranks = mapply(to_string_seq, wright_LB, wright_UB)
  ) %>%
  select(c(STATE, ISO, RANK, RK, proposed_string_ranks, wright_string_ranks, in_wright, in_proposed)) %>%
  pivot_longer(
    cols = c(proposed_string_ranks, wright_string_ranks),
    names_to = "approach",
    values_to = "string_ranks"
  ) %>%
  # mutate(approach = factor(approach, levels = c("wright_string_ranks", "proposed_string_ranks"))) %>%
  separate_rows(string_ranks, sep=",") #%>%
#   select(c(STATE, ISO, RANK, string_ranks))

dat_to_plot$string_ranks <- as.integer(dat_to_plot$string_ranks)

dat_to_plot$highlight <- ifelse(
  dat_to_plot$RK == as.numeric(dat_to_plot$string_ranks), "highlight", 
  "normal") 

dat_to_plot <- dat_to_plot%>% 
  mutate(
    red = ifelse(
      ifelse(
        approach == "proposed_string_ranks",
        mapply(function(r, x) r %in% x, string_ranks, in_proposed),
        mapply(function(r, x) r %in% x, string_ranks, in_wright)
      ),
      "red",
      "normal"
    )
  ) %>% mutate(highlight = case_when(
    highlight == 'normal' & red == 'normal' ~ 'normal',
    highlight != 'normal'                   ~ highlight,
    TRUE                                    ~ red
  ))


# dat_to_plot %>% mutate(redd = ifelse(approach == 'proposed_string_ranks', dat_to_plot$string_ranks %in% dat_to_plot$in_wright, dat_to_plot$string_ranks %in% dat_to_plot$in_proposed)) %>% filter(ISO=="WV")




shading_background <- data.frame(
  # ymin = seq(0.5, 48.5, by = 6), 
  # ymax = seq(3.5, 51.5, by = 6) 
  ymin = seq(0.5, num_elements - 3.5, by = 6), 
  ymax = seq(3.5, num_elements + 0.5, by = 6) 
)

ggplot() +
  geom_rect(data = shading_background, 
            aes(xmin = -Inf, xmax = Inf, ymin = ymin, ymax = ymax), 
            fill = "gray", alpha = 0.3) +
  # geom_label(data = dat_to_plot, 
  #            aes(x = reorder(STATE, RANK),
  #                y = as.numeric(string_ranks),
  #                label = ISO,
  #                color = highlight, 
  #                fill = highlight), 
  #            size = 2.45,
  #            label.padding = unit(0.01, "lines"),
  #            linewidth = NA) +   
  geom_label(
    data = dat_to_plot,
    aes(
      x = reorder(STATE, RANK),
      y = as.numeric(string_ranks),
      label = ISO,
      color = highlight,
      fill = highlight
    ),
    size = 2.45,
    # label.padding = unit(c(0.02, 0.04, 0.02, 0.04), "lines"),
    label.padding = unit(c(0.15, 0.1, 0.25, 0.1), "lines"),
    linewidth = NA
  ) +
  facet_wrap(~ factor(approach, levels = c("wright_string_ranks", "proposed_string_ranks")), 
             # nrow = 2,
             labeller = as_labeller(facet_names)) +
  # facet_wrap("approach", labeller = as_labeller(facet_names)) + 
  scale_color_manual(values = c("highlight" = "white", 
                                "normal" = "black",
                                "red" = 'red')) +
  scale_fill_manual(values = c("highlight" = "gray28", 
                               "normal" = "transparent",
                               'red' = 'transparent')) +
  
  scale_y_continuous(breaks = 1:num_elements, 
                     expand = expansion(mult = c(0.005, 0.05))) +
  labs(title = suptitle,#stringr::str_to_title(APP),
       x = 'States', y = expression(r[k])) +
  theme_bw() +
  theme(
    # plot.title = element_blank(),  
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.title.y = element_text(angle = 0, hjust = 0.5, vjust = 1),
    axis.line = element_line(colour = "gray"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  guides(color = "none", fill = "none") 

