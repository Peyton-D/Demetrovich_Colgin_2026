%% pipeline.m
% follows the analyses in order to recreate the data figures from the paper

% 1. read in data struct
load('cellStruct1_14_26.mat')

% 2. Figs. 2-4: Ratemaps, Spatial Correlation, and Rate Overlap
place_cell_metrics(cellStruct)

% 3. Fig. 5: Rat exploration time on track
stim_explore_time(cellStruct)

% 4. Figs. 6-9,S4: dentate spike rates and PETHs - REQUIRES ACCESS TO EACH
% SESSION'S LFP DATA
dsMetrics_revision(cellStruct)

%% optional / supplmental

% 4. Figs. S2-S3: dentate spike detection and classification methods


