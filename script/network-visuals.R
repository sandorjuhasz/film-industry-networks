## Brokering the core and the periphery - creative success and collaboration networks in the film industry ##
## script by Sandor Juhasz

## packages ##
library(data.table)
library(dplyr)
library(igraph)
library(bc3net)
library(ggraph)
library(graphlayouts)
library(patchwork)

# for reproduction
set.seed(19)


## visualize CORE / BROKER / AWARD winner movie creators on the graph of 2006

# data_in
data <- fread("../data/creator_movie_BASE_1975_2010.csv", sep=";")


# networks for each year in 1990-2010
G <- list() # list of graphs

for (i in 1:length(seq(1990, 2010, 1))){
  periodbase <- data[which(data$year<(1990+i) & data$year>(1982+i)),]  # 7-year moving window
  periodbase <- select(periodbase, creator_id, film_id)
  
  mat <- as.matrix(table(periodbase))
  adjmat <- mat %*% t(mat) # adjacency matrix
  adjmat[adjmat > 1] <- 1
  diag(adjmat) <- 0
  
  # create a graph object
  G[[i]] <- graph.adjacency(adjmat, mode='undirected') 
  
  rm(periodbase, mat, adjmat)
  gc()
}

# keep the graph of 2006 as an example
graph2006 <- G[[17]]

rm(G)
gc()



# add three properties to network nodes - CORE / BROKER / AWARD winner

# - CORE
nodedata <- data.frame(V(graph2006)$name, coreness(graph2006)) # kcore measure
colnames(nodedata) <- c("creator_id", "coreness")

# create core_dummy
nodedata$core_dummy <- 0
nodedata$third_quantile <- quantile(nodedata$coreness, 0.75, names=F)
nodedata$core_dummy[which(nodedata$coreness>nodedata$third_quantile)] <- 1
nodedata <- select(nodedata, creator_id, core_dummy)


# - BROKER
ebetw <- edge_betweenness(graph2006) # edge betweenness of ties
E(graph2006)$ebetw <- ebetw # set as edge property
betw <- strength(graph2006, weights=ebetw) # sum edge betweenness by nodes
betw <- betw/(degree(graph2006)) 
betw[is.na(betw)] <- 0
betw <- log(betw +1)
betw_df <- data.frame(V(graph2006)$name, betw)
colnames(betw_df) <- c("creator_id", "betw")

# create broker_dummy
betw_df$broker_dummy <- 0
betw_df$betw_quan <- quantile(betw_df$betw, 0.75, names=FALSE) ####
betw_df$broker_dummy[which(betw_df$betw>betw_df$betw_quan)] <- 1
betw_df <- select(betw_df, creator_id, broker_dummy)

# merge
nodedata <- merge(nodedata, betw_df, by=c("creator_id"))
 

# - AWARD winner
awards <- fread("../data/award_winners.csv", sep=";")
awards <- select(filter(awards, year==2006), creator_id, award) # 7-year moving window
awards <- unique(data.table(awards))

# merge
nodedata <- merge(nodedata, awards, by=c("creator_id"), all.x=TRUE)
nodedata[is.na(nodedata)] <- 0  #replace na with 0


# core and broker and award winner nodes
nodedata$all <- 0
nodedata$all[which(nodedata$core_dummy==1 & nodedata$broker_dummy==1 & nodedata$award==1)] <- 1


# add node properties to graph attributes
V(graph2006)$core_dummy <- nodedata$core_dummy
V(graph2006)$broker_dummy <- nodedata$broker_dummy
V(graph2006)$award <- nodedata$award
V(graph2006)$all <- nodedata$all




### graph PLOTS
# networks are created by the 'graphlayouts' package

# keep only the giant component
graph <- getgcc(graph2006) # from the 'bc3net' package

# to put more central nodes to the middle of the chart
degree <- degree(graph, normalized=TRUE)

# set up a baseline layoutt
layout1 <- layout_with_centrality(graph, degree, iter = 500, tseq=seq(0,1,0.1))


# plot1 - CORE nodes in focus
plot1 <- ggraph(graph, layout = "manual", node.positions = data.frame(x = layout1[,1], y = layout1[,2])) +
  draw_circle(use = "cent") +
  annotate_circle(degree, format="", pos="bottom") +
  geom_edge_link(edge_color = "black", edge_width=0.3) +
  geom_node_point(aes(fill=as.factor(core_dummy), size=as.factor(award)), shape=21) +
  scale_fill_manual(values=c("grey", "darkgreen")) +
  scale_size_manual(values=c(6, 12)) +
  scale_linetype_manual(values=c(0.5, 1.5)) +
  theme_graph() +
  theme(legend.position = "none") +
  coord_fixed()


# plot2 - BROKER nodes in focus
plot2 <- ggraph(graph, layout = "manual", node.positions = data.frame(x = layout1[,1], y = layout1[,2])) +
  draw_circle(use = "cent") +
  annotate_circle(degree, format="", pos="bottom") +
  geom_edge_link(edge_color = "black", edge_width=0.3) +
  geom_node_point(aes(fill=as.factor(broker_dummy), size=as.factor(award)), shape=21) +
  scale_fill_manual(values=c("grey", "blue")) +
  scale_size_manual(values=c(6, 12)) +
  scale_linetype_manual(values=c(0.5, 1.5)) +
  theme_graph() +
  theme(legend.position = "none") +
  coord_fixed()


#plot3 - AWARD winner nodes in focus
plot3 <- ggraph(graph, layout = "manual", node.positions = data.frame(x = layout1[,1], y = layout1[,2])) +
  draw_circle(use = "cent") +
  annotate_circle(degree, format="", pos="bottom") +
  geom_edge_link(edge_color = "black", edge_width=0.3) +
  geom_node_point(aes(fill=as.factor(all), size=as.factor(award)), shape=21) +
  scale_fill_manual(values=c("grey", "orange")) +
  scale_size_manual(values=c(6, 12)) +
  scale_linetype_manual(values=c(0.5, 1.5)) +
  theme_graph() +
  theme(legend.position = "none") +
  coord_fixed()



# saved the plot
title <- "networks-core-broker-awardwinner"
file_name <- paste0("../figures/", title, ".png")
png(file_name, width=1600, height=700, units = 'px')

par(mar=c(0,0,0,0), bg = NA)

plot_full <- (plot1 + plot2 + plot3)
wrap_elements(plot_full) + ggtitle('Core, Broker and Core & Broker & Award winner creators in the network of 2006') + theme(plot.title = element_text(size = 40, face = "bold"))

dev.off()


