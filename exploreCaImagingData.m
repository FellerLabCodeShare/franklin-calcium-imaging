% This script is a simple way to visualize data from a single movie. Drag
% and drop the dataset from the movie into the workspace, then run what
% follows. 

% Maximum number of neurons and frames to display in a heatmap 
max_neurons = 300;
max_frames = 1000; 

% Run this to process datasets that are in the data guide table 
% d = processMovies('villy calcium imaging data guide.xlsx'); 

% Extracts traces from all the neurons in the movie 
movie_list = dataset.getFullMovieList();
movie = movie_list{1};
traces = dataset.getTraces(dataset.getNeuronIDList(), movie);

% Plots a heatmap of the fluorescence traces for all neurons 
figure
%imagesc(zscore(traces')'); % Plot the z-scored DF/F traces for each cell
imagesc(traces); % Plot the raw DF/F traces for each cell 
caxis([0 0.1]); % Set the limits on the color axis 
ylabel('Neurons');
xlabel('Frames'); 
title([num2str(dataset.date), ' ', dataset.name]); 
set(gcf, 'Position', [1420, 90, 430, 240]); 
set(gca, 'Position', [0.1, 0.1, size(traces, 2) / max_frames - 0.1, size(traces, 1) / max_neurons]);
xticks([100]);
colorbar  

% Plots traces of all neurons with a scalebar (1% dF/F, 60 s)
dataset.plotTracesSimple(1.48, 0.01, 0.02); % Framerate, offset, threshold for considering a cell 'active' 
title([num2str(dataset.date), ' ', dataset.name]); 

% Generate the correlation matrix for all the neurons
R = corrcoef(traces'); 
figure
imagesc(R);
caxis([-1 1]); 




