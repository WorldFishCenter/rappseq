---
title: Our classifiers
date: "2021-07-29"
---

We currently support three classifiers. One for species identification and two for high resolution identification of *Yersenia ruckeri* and *Streptococcus agalactiae*.

## Species classifier

A species-level classifier has been trained to detect all bacterial species present in our reference database (link) and a further 18,000 microbial reference genomes from the gold-standard RefSeq obtained from NCBI. The RefSeq genomes enable species level identification of microbial isolates previously characterized and made public. 

## Sub-species classifiers

Sub-species level classifiers were trained to accurately assign unknown raw nanopore sequences to serotype, sequence type (ST) or biotype levels. As a proof-of-concept and to show that this was possible we used two major bacterial groups species as examples: a gram-positive bacteria,  Group B Streptococcus (GBS, *Streptococcus agalactiae*), and a gram negative bacteria, *Yersinia ruckeri*.

### *Streptococcus agalactiae*

For GBS, our inbuilt classifiers can identify the major serotypes and multi-locus sequence types of GBS isolates known to affect fish, marine mammals, human and terrestrial animals. The GBS sequence types covered by our classifier include STs: 1, 7, 12, 17, 19, 22, 23, 26, 61, 103, 110, 260, 261, 283, 452, 459, 552, 609, 617, 736 and 739. The GBS serotypes covered by our classifier include serotypes Ia, Ib, II, III, IV, V, and VI. 

### *Yersinia ruckeri*

For Y. ruckeri, our inbuilt classifiers can detect O-antigen serotype (O1a, O1b and O2) and biotype 1 and 2. More 

Lab in a Backpack ID tool is still under development and will be readily extended and scaled to cater other bacterial species, viruses and parasites. Once new genomic information of aquaculture pathogens are sequenced and made available, they will be added to our reference database and our classifiers re-trained to cover them. The source code behind our classifiers is readily adaptable for a variety of other applications, not limited to pathogen identification. A classifier to correctly infer AMR phenotype of streptococcal fish pathogens (Streptococcus iniae and S. agalactiae) is under development. Work in progress (coming in 2022).
