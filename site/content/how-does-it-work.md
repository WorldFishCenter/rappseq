---
title: How does the ID tool work?
date: "2021-07-26"
draft: false
---

Lab in a Backpack ID tool is a cloud-based system designed for rapid genomic identification of aquaculture pathogens.

It is based on long read sequence data generated on Oxford Nanopore Technologies (ONT) portable sequencing platform, usually a MinION device. 

The portal includes several in-built classifiers for reliable identification of bacterial pathogens at species, serotype, biotype and MLST (multilocus sequence type) levels. 

In brief, users enter long read nanopore sequence data they generated from unknown bacterial DNA by uploading a FASTQ file (standard output text file for ONT platform. When users select the “assign” button, our inbuilt classifiers compare the sequence or sequences against our reference database that is dimensionally compressed for storage and speed, by retaining only diagnostic k20-mers (short overlapping substrings) that are unique to each taxon. It usually takes about 10-20s for every 1000 sequences uploaded for the classifiers to process and return output results to users. 

Output results displayed on the portal are used to guide users on the genus, species, sequence type (ST), biotype and/or serotype-level ID of the sequenced bacterial pathogen but also provide safety alerts to human (zoonotic/foodborne pathogens) and aquatic animals with some immediate recommendations to deal with the disease.

For more information about our long read classifiers see below.
