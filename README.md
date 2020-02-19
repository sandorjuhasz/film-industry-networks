# Collaboration networks in the Hungarian film industry

###### This is a public repository for the article

Juhász, S.; Tóth, G. and Lengyel, B. (2019): Brokering the core and the periphery - creative success and collaboration networks in the film industry. *PLOS One*, -In Press-

[Abstract]
*In collaboration-based creative industries, such as film production, creators in the network core enjoy prestige and legitimacy that are key for creative success. However, core creators are challenged to maintain diverse access to new ideas or alternative views that often emerge from the network periphery. In this paper, we demonstrate that creators in the network core can increase the probability of their creative success by brokering peripheral collaborators to the core. The argument is tested on a dynamic collaboration network of movie creators constructed from a unique dataset of Hungarian feature films for the 1990-2009 period. We propose a new way to capture brokers’ role in core/periphery networks and provide evidence that being in the core and at the same time bridging between the core and the periphery of the network significantly increases the likelihood of award winning.* <br>

*link* <br>

## DATA <br>

Description - two short dataset collected from the website of the Hungarian Film Archive *link*. Both datasets are anonymized and only used for the purpose of the paper above. <br>

file: *creator_movie_BASE_1975_2010.csv* <br>

file: *award_winners.csv* <br>



## Scripts <br>

file: *datacollection-single-film-page.ipynb*<br>

description <br>

file: *datacollection-all-movies-by-year.ipynb*<br>

description <br>

file: *datacollection-entire-film-archive.ipynb*<br>

description <br>

file: *datacollection-entire-film-archive.py* <br>

description


## Figures <br>
The figure below represents core, broker and award winner creators in the network of 2006. Uniformly large nodes represent award winners in all three graphs. Colours of the nodes show their special positions as Core, Broker and Core & Broker & Award winner creators. Nodes with a higher degree of centrality are closer to the center of the circular layout. The network is based on a 7-year moving window, where nodes represent movie creators and edges represent collaboration on all movies made during the 7-year period. The layout is created by the graphlayouts R package. <br>
link: *https://github.com/schochastics/graphlayouts*<br/>
<br/>
![](figures/networks-core-broker-awardwinner.png)<br/>
<br/>



