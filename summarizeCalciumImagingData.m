% Produces a summary analysis of the calcium imaging experiments. This
% script is a bit more 'formal' than exploreCalciumImagingData - it makes more plots
% but it's a bit more difficult to look at data from one movie at a time. 

%% Reads the experiment table and makes a table with one row per neuron 
g_name = 'Villy epi imaging guide - demo.xlsx';
root_directory = 'C:\Users\Feller Lab\Google Drive\collaboration\Villy calcium imaging';
max_movie_frames = 2000; 
framerate = 20; 
max_neurons = 500; % Maximum number of neurons allowed in a field of view 
d = buildTableOfNeurons(g_name, root_directory, max_movie_frames, max_neurons);

%% Select a subset of the data
%d = d(d.date == 190709, :); 

%% Analyze and add activity bouts to the data table 
active_threshold = 0.02; % Defines whether a cell is active 

% Adds an array of active and inactive durations to the table 
d = summarizeActivityBouts(d, active_threshold); 

%% Analyze and add correlations to the data table 
d = summarizeCorrelations(d); 

%% Analyze and add events (activity peaks) to the data table 
min_prominence = 0.02; 
display_findpeaks = false; 
d = summarizeEvents(d, min_prominence, display_findpeaks); 

%% Plot all the traces for each movie 
movies = unique(d.movie_name);
for i = 1:length(movies)
    cur_d = d(strcmp(d.movie_name, movies{i}), :); 
    plotSpacedTraces(cur_d, framerate, 0.01, 0.02); % Framerate, offset, threshold for considering a cell 'active' 
    title(unique(cur_d.data_name), 'Interpreter', 'none'); 
end 

%% Compare summary statistics across cells treated with different viruses
d_cre = d(strcmp(d.virus, 'Cre'), :);
d_gfp = d(strcmp(d.virus, 'GFP'), :); 

% Parameters for plots
hist_bw = 1; % Seconds  

% Baseline intensity (F0)
figure
hold on 
histogram(d_gfp.f0, 'Normalization', 'probability', 'BinWidth', 5);
histogram(d_cre.f0, 'Normalization', 'probability', 'BinWidth', 5);
hold off
legend({'GFP', 'Cre'}); 
xlabel('Baseline fluorescence intensity (a.u.)'); 
ylabel('Proportion of cells'); 
set(gcf, 'Renderer', 'painters');

% Active duration 
figure
hold on 
gfp_active = d_gfp.active_durations / framerate;
cre_active = d_cre.active_durations / framerate;
gfp_active = gfp_active(~isnan(gfp_active));
cre_active = cre_active(~isnan(cre_active));
histogram(gfp_active, 'Normalization', 'probability', 'BinWidth', hist_bw);
histogram(cre_active, 'Normalization', 'probability', 'BinWidth', hist_bw);
hold off 
legend({'GFP', 'Cre'}); 
xlabel('Duration (s)'); 
ylabel('Proportion of active epochs'); 
set(gcf, 'Renderer', 'painters');

% Inactive duration 
figure
hold on 
gfp_inactive = d_gfp.inactive_durations / framerate;
cre_inactive = d_cre.inactive_durations / framerate;
gfp_inactive = gfp_inactive(~isnan(gfp_inactive));
cre_inactive = cre_inactive(~isnan(cre_inactive));
histogram(gfp_inactive, 'Normalization', 'probability', 'BinWidth', hist_bw);
histogram(cre_inactive, 'Normalization', 'probability', 'BinWidth', hist_bw);
hold off 
legend({'GFP', 'Cre'}); 
xlabel('Duration (s)'); 
ylabel('Proportion of inactive epochs'); 
set(gcf, 'Renderer', 'painters');

% Maximum duration of activity 
figure
hold on 
histogram(max(d_gfp.active_durations, [], 2) / framerate, 'Normalization', 'probability',...
    'BinWidth', hist_bw);
histogram(max(d_cre.active_durations, [], 2) / framerate, 'Normalization', 'probability',...
    'BinWidth', hist_bw);
hold off 
legend({'GFP', 'Cre'}); 
xlabel('Maximum active duration (s)'); 
ylabel('Proportion of cells'); 
set(gcf, 'Renderer', 'painters');
xlimits = xlim;
xlim([0 xlimits(2)]); 

% Maximum duration of inactivity 
figure
hold on 
histogram(max(d_gfp.inactive_durations, [], 2) / framerate, 'Normalization', 'probability',...
    'BinWidth', hist_bw);
histogram(max(d_cre.inactive_durations, [], 2) / framerate, 'Normalization', 'probability',...
    'BinWidth', hist_bw);
hold off 
legend({'GFP', 'Cre'}); 
xlabel('Maximum inactive duration (s)'); 
ylabel('Proportion of cells'); 
set(gcf, 'Renderer', 'painters');
xlimits = xlim;
xlim([0 xlimits(2)]); 

% Percent of the time active
figure
hold on 
histogram(nansum(d_gfp.active_durations, 2) / max_movie_frames * 100, 'Normalization', 'probability',...
    'BinWidth', 1);
histogram(nansum(d_cre.active_durations, 2) / max_movie_frames * 100, 'Normalization', 'probability',...
    'BinWidth', 1);
hold off 
legend({'GFP', 'Cre'}); 
xlabel('Proportion of the time in active state (%)'); 
ylabel('Proportion of cells'); 
set(gcf, 'Renderer', 'painters');
xlimits = xlim;
xlim([0 xlimits(2)]); 

% Mean pairwise correlation
figure
hold on 
histogram(d_gfp.mean_correlation, 'Normalization', 'probability', 'BinWidth', 0.01);
histogram(d_cre.mean_correlation, 'Normalization', 'probability', 'BinWidth', 0.01);
hold off 
legend({'GFP', 'Cre'}, 'Location', 'NorthWest'); 
xlabel('Mean pairwise correlation'); 
ylabel('Proportion of cells'); 
set(gcf, 'Renderer', 'painters');
xlimits = xlim;
xlim([0 xlimits(2)]);

figure 
imagesc(d_cre.correlation);
title('Cre pairwise correlations'); 
caxis([0.7, 1]); 

figure
imagesc(d_gfp.correlation); 
title('GFP pairwise correlations'); 
caxis([0.7, 1]);

% Does the mean pairwise correlation in a movie scale with the number of
% cells? 
movies = unique(d.movie_name, 'stable'); 
mean_correlations = NaN * ones(1, length(movies)); 
neuron_counts = NaN * ones(1, length(movies)); 
for i = 1:length(movies)
    cur_movie = movies{i};
    cur_d = d(strcmp(d.movie_name, cur_movie), :);
    mean_correlations(i) = nanmean(cur_d.correlation(:));
    neuron_counts(i) = size(cur_d, 1);
end 
    
figure
plot(neuron_counts, mean_correlations, 'ok', 'MarkerFaceColor', 'k');
xlabel('Number of neurons');
ylabel('Mean pairwise correlation coefficient'); 
axis square

% Is the frequency of events different? 
movie_duration = (size(d.trace, 2) / framerate); 
figure
histogram(sum(~isnan(d_gfp.event_frames), 2) / movie_duration, ...
    'Normalization', 'probability', 'BinWidth', 0.05);
hold on 
histogram(sum(~isnan(d_cre.event_frames), 2) / movie_duration, ...
    'Normalization', 'probability', 'BinWidth', 0.05);
hold off
xlabel('Events per second');
ylabel('Proportion of cells'); 
legend({'GFP', 'Cre'}); 
xlim([0 2]); 

% Is the mean prominence of events different? 
figure
histogram(nanmean(d_gfp.event_fs, 2), 'Normalization', 'probability', 'BinWidth', 0.01);
hold on 
histogram(nanmean(d_cre.event_fs, 2), 'Normalization', 'probability', 'BinWidth', 0.01);
hold off
xlabel('Mean event prominence (dF/F)');
ylabel('Proportion of cells'); 
legend({'GFP', 'Cre'}); 
set(gcf, 'Renderer', 'painters');

% Is the max prominence of events different? 
figure
histogram(nanmax(d_gfp.event_fs, 2), 'Normalization', 'probability', 'BinWidth', 0.01);
hold on 
histogram(nanmax(d_cre.event_fs, 2), 'Normalization', 'probability', 'BinWidth', 0.01);
hold off
xlabel('Maximum event prominence (dF/F)');
ylabel('Proportion of cells'); 
legend({'GFP', 'Cre'}); 
set(gcf, 'Renderer', 'painters');

%% Analysis in the frequency domain
% calculate FFTs of the traces
d.fft = fft(d.trace')'; 


