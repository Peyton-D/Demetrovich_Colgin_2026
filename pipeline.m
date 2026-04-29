%% pipeline.m
% run each section sequentially to recreate the figures from the paper - CODE WILL NOT RUN WITHOUT DATA STORED LOCALLY IN LOCATIONS SPECIFIED IN "cellStruct"!
% CODE PROVIDED FOR TRANSPARENCY

%% 1. read in data struct
load('cellStruct1_14_26.mat');

%% 2. Figs. 2-4: Ratemaps, global and rate remapping
place_cell_metrics(cellStruct, 'mean');

%% 3. Fig. 5: Rat exploration time on track
exploration_metrics(cellStruct);

%% 3.5. Fig. S2-S3: Dentate spike detection and classification
evaluate_scoring.m; % find the best standard deviation threshold (4.0)
ds_methods_figure.m; 
rerun_ds_detection(cellStruct, 4.0); % use the best standard deviation threshold for detection

%% 4. Figs. 6-9,S4: dentate spike rates and PETHs
dentate_spike_metrics(cellStruct);


