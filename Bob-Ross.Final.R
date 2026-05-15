library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
library(forcats)
library(scales)
library(patchwork)
library(readr)

# ── 1. LOAD DATA ──────────────────────────────────────────────────────────────
bob_ross <- read_csv("C:/Users/RNE/Downloads/bob_ross_paintings.csv",
                     show_col_types = FALSE)

# ── 2. WRANGLE ────────────────────────────────────────────────────────────────
# Split hex and color name columns INDEPENDENTLY to prevent misalignment,
# then rejoin by col_id. str_extract ensures only valid hex survives.

hex_long <- bob_ross %>%
  select(season, episode, num_colors, color_hex) %>%
  mutate(color_hex = str_remove_all(color_hex, "\\[|\\]|'")) %>%
  separate_longer_delim(color_hex, delim = ", ") %>%
  mutate(color_hex = str_extract(color_hex, "#[0-9A-Fa-f]{6}")) %>%
  filter(!is.na(color_hex)) %>%
  group_by(season, episode) %>%
  mutate(col_id = row_number()) %>%
  ungroup()

name_long <- bob_ross %>%
  select(season, episode, colors) %>%
  mutate(colors = str_remove_all(colors, "\\[|\\]|'")) %>%
  separate_longer_delim(colors, delim = ", ") %>%
  mutate(colors = str_trim(str_remove_all(colors, "\\\\n"))) %>%
  filter(colors != "") %>%
  group_by(season, episode) %>%
  mutate(col_id = row_number()) %>%
  ungroup()

colors_long <- hex_long %>%
  left_join(name_long, by = c("season", "episode", "col_id")) %>%
  filter(!is.na(colors), colors != "")

# ── 3. COLOR FREQUENCY ────────────────────────────────────────────────────────
# Dataset has exactly 17 unique colors across all 403 paintings / 31 seasons
color_order <- colors_long %>%
  count(colors, color_hex, sort = TRUE) %>%
  group_by(colors) %>%
  slice_max(n, n = 1, with_ties = FALSE) %>%
  ungroup()

color_hex_lookup <- setNames(color_order$color_hex, color_order$colors)
all_colors       <- color_order$colors   # all 17

# ── 4. HEATMAP DATA ───────────────────────────────────────────────────────────
# Each season has exactly 13 episodes (verified: 403 paintings / 31 seasons)
season_totals <- bob_ross %>% count(season, name = "n_episodes")  # all 13

season_color_pct <- colors_long %>%
  count(season, colors) %>%
  left_join(season_totals, by = "season") %>%
  mutate(
    pct    = n / n_episodes,
    colors = factor(colors, levels = rev(all_colors))  # most-used at top
  ) %>%
  complete(season, colors, fill = list(pct = 0, n = 0)) %>%
  mutate(fill_hex = color_hex_lookup[as.character(colors)])

# ── 5. BAR CHART DATA ─────────────────────────────────────────────────────────
bar_data <- color_order %>%
  mutate(colors = fct_reorder(colors, n))

# ── 6. THEME (WHITE BACKGROUND) ───────────────────────────────────────────────
bg_color    <- "#FFFFFF"
panel_color <- "#F7F7F5"
grid_color  <- "#E8E8E8"
text_dark   <- "#1A1A2E"
text_mid    <- "#555555"
accent      <- "#2C5F8A"   # deep blue — nods to Bob Ross's beloved Phthalo Blue

# ── 7. HEATMAP ────────────────────────────────────────────────────────────────
p_heat <- ggplot(season_color_pct,
                 aes(x = factor(season), y = colors,
                     fill = fill_hex, alpha = pct)) +
  geom_tile(color = "#FFFFFF", linewidth = 0.7) +
  scale_fill_identity() +
  scale_alpha_continuous(range = c(0.08, 1), guide = "none") +
  scale_x_discrete(
    name   = "Season  (1–31,  each with 13 episodes)",
    expand = expansion(0)
  ) +
  scale_y_discrete(name = NULL, expand = expansion(0)) +
  labs(
    title    = "The Colors of Bob Ross",
    subtitle = "Proportion of episodes per season in which each paint color was used  \u00b7  Darker = more episodes"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.background  = element_rect(fill = bg_color,    color = NA),
    panel.background = element_rect(fill = panel_color, color = NA),
    panel.grid       = element_blank(),
    plot.title       = element_text(face = "bold", size = 22, color = text_dark,
                                    family = "serif", margin = margin(b = 4)),
    plot.subtitle    = element_text(size = 9, color = text_mid, lineheight = 1.4,
                                    margin = margin(b = 10)),
    axis.text.y      = element_text(size = 9,  color = text_dark, hjust = 1),
    axis.text.x      = element_text(size = 8, color = text_mid, angle = 45, hjust = 1, vjust = 1),
    axis.title.x     = element_text(size = 8,  color = text_mid, margin = margin(t = 6)),
    axis.ticks       = element_blank(),
    plot.margin      = margin(20, 15, 10, 20)
  )

# ── 8. BAR CHART ──────────────────────────────────────────────────────────────
p_bar <- ggplot(bar_data, aes(x = colors, y = n, fill = color_hex)) +
  geom_col(width = 0.72, color = "#CCCCCC", linewidth = 0.25) +
  scale_fill_identity() +
  coord_flip() +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.14)),
    name   = "Episodes using this color",
    labels = label_number()
  ) +
  geom_text(aes(label = n), hjust = -0.2, size = 3, color = text_dark) +
  labs(
    title    = "All 17 Colors  \u00b7  Overall Frequency",
    subtitle = "Out of 403 total paintings across 31 seasons",
    x        = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.background    = element_rect(fill = bg_color,    color = NA),
    panel.background   = element_rect(fill = panel_color, color = NA),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(color = grid_color, linewidth = 0.5),
    panel.grid.minor   = element_blank(),
    plot.title         = element_text(face = "bold", size = 13, color = text_dark,
                                      family = "serif"),
    plot.subtitle      = element_text(size = 8,  color = text_mid),
    axis.text          = element_text(size = 9,  color = text_dark),
    axis.title.x       = element_text(size = 8,  color = text_mid, margin = margin(t = 5)),
    axis.ticks         = element_blank(),
    plot.margin        = margin(20, 20, 10, 10)
  )

# ── 9. COMBINE ────────────────────────────────────────────────────────────────
combined <- p_heat + p_bar +
  plot_layout(widths = c(2.8, 1)) +
  plot_annotation(
    caption = "Source: Jared Wilber  \u00b7  TidyTuesday 2023 Week 08  \u00b7  403 paintings, 31 seasons, 17 unique colors  \u00b7  Redesign per Wilke (2019)",
    theme   = theme(
      plot.background = element_rect(fill = bg_color, color = NA),
      plot.caption    = element_text(size = 7, color = text_mid,
                                     margin = margin(t = 4, b = 8))
    )
  )

# ── 10. SAVE ──────────────────────────────────────────────────────────────────
ggsave(
  filename = "bob_ross_redesign.png",
  plot     = combined,
  width    = 22, height = 10, dpi = 220, bg = bg_color
)
print(combined)

cat("Done! Saved as bob_ross_redesign.png in your working directory.\n")