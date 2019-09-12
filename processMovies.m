% This function is designed for calcium imaging at cellular resolution. 
% The code reads in a data guide spreadsheet that lists fields of view and movies. 
% For movies that do not already have processed data associated with them, 
% this code will load the movie and generate a delta F/F. It will then load ROIs
% and extract fluorescence traces for individual cells. Data will be stored in 
% a set of 'fov' (field of view) objects that contain 'neuron' objects. 
% This function works with MATLAB 2018a but has not been tested with earlier versions. 

function [d] = processMovies(data_guide_name)

    % Detect import options for the data guide spreadsheet
    opts = detectImportOptions(data_guide_name);
    
    % Ensure that the 'data_name' column of the table is a string array
    opts = setvartype(opts,{'data_name'},'string');

    % Load the data guide spreadsheet as a table 
    d = readtable(data_guide_name, opts); 

    % Iterate over the movies referenced in each row of the data guide
    for i = 1:size(d,1)

        % If there is not already a dataset for this movie and the data
        % should be included
        if ismissing(d.data_name(i)) && d.include(i) 
            
            % Let the user know
            disp(['Dataset not found for ', d.movie_name{i}, ', making a new one']); 
            
            % Process the movie to create the dataset
            dataset = processMovie(d, i);
            
            % Update the table with the name of the dataset
            d.data_name(i) = nameDataset(d, i);
            
            % Save the dataset
            tic;
            saveDataset(dataset, d, i);
            disp(['Took ', num2str(toc), ' to save the dataset']); 
            
        end
    end
    
    % Save the updated spreadsheet as a new version within whatever
    % directory matlab is pointed to when this function is called 
    saveSpreadsheet(d, data_guide_name); 
    
end 

% Saves an updated version of the data guide spreadsheet
function [] = saveSpreadsheet(d, data_guide_name)

    % Get the parts of the data guide spreadsheet's filename
    [filepath,name,ext] = fileparts(data_guide_name);
    
    % Save the new spreadsheet in the same path with the same extension
    writetable(d, [filepath, name, ' updated', ext]); 
end

% Processes a movie to generate a fov dataset. For now, fields of view and
% movies are equivalent. The implication of this is that the analysis
% pipeline currently allows for only one movie per field of view, so no
% registration of the same neurons between multiple movies. 
function [fov] = processMovie(d, i) 

    % Create a new field of view object with the required information: name
    % and date. Here, the name will be the virus, well number, and fov
    % number
    fov = FOV([d.virus{i}, ' well ', num2str(d.well_n(i)),...
        ' fov ', d.plate{i}], d.date(i));
    
    % Loads the movie
    tic;
    m = loadMovie(d, i); 
    disp(['Took ', num2str(toc), ' to load the movie']); 
    
    % Makes a delta F/F movie from the raw movie 
    tic;
    [m_df_overf, f0] = makeDFOverF(m);
    disp(['Took ', num2str(toc), ' to make a DF/F movie']); 
    
    % Loads regions of interest for the Neurons in the FOV
    rois = loadROIs(d, i);
    
    % Adds neurons to the FOV object 
    tic; 
    fov = addNeurons(d.movie_name{i}, fov, rois, m_df_overf, f0);
    disp(['Took ', num2str(toc), ' to generate Neuron objects']); 
    
end

% Adds neurons to a FOV 
function [fov] = addNeurons(movie_name, fov, rois, m_df_overf, f0)

    % Get traces (what are the dimensions of the array?) and a mask of the rois 
    [traces, f0s, rois_mask] = getRoiTraces_culture(m_df_overf, f0, rois); 
    
    % Neuron IDs will be their numbering in the ROI mask
    ids = unique(rois_mask);
    
    % The background of the mask has 0, don't use this as an ID
    ids = ids(ids~= 0); 
    
    % For each ID
    for i = 1:length(ids)
        id = ids(i);
        
        % Create the neuron object  
        n = neuron(id);
        
        % Add a movie to the neuron object 
        n.addMovie(movie_name, rois{i}, traces{i}, f0s(i));
        
        % Add the neuron to the field of view object
        fov.addNeuron(n);
    end
        
end

% Loads a calcium imaging movie 
function [m] = loadMovie(d, i)
    filename = fullfile(d.path{i}, d.movie_name{i});
    m = readTifStack(filename); 
end

% Makes a deltaF/F movie from a raw movie 
function [m_df_overf, f0] = makeDFOverF(m)

    % Convert the movie to double precision floating point numbers so that
    % image math works well
    m = double(m); 
    
    % Baseline image is the median projection.
    %f0 = median(m, 3);
    
    % Baseline image is the bottom 5th percentile projection
    f0 = prctile(m, 5, 3); 
    
    % Subtract off the baseline and normalize by the baseline.
    m_df_overf = (m - f0) ./ f0; 
    
    % Convert movie back to uint16 so subsequent steps go faster
    %m_df_overf = uint16(m_df_overf); 
    
end

% Loads a set of ROIs from imageJ, then return a mask
function [rois] = loadROIs(d, i)

    % Infer the name of the roi file from other information in the table.
    % This requireds that the roi file has a very standard name. 
    [~, movie_name, ~] = fileparts(d.movie_name{i});
    filename_suffix = ['rois for ', movie_name, '.zip'];  
    
    % Combine the filename and path 
	filename = fullfile(d.path{i}, filename_suffix);
    
    % Call a function that reads imageJ's circular ROIs and generates a
    % mask
    rois = ReadImageJROI(filename);
    
end

% Saves a dataset within the path specified in the data guide table 
function [] = saveDataset(dataset, d, i)
    
    % Build the full file name 
    data_name = d.data_name(i);
    path = d.path{i};
    filename = fullfile(path, data_name);
    
    % Save the dataset
    save(strcat(filename, '.mat'), 'dataset'); 
end

% Names a dataset according to the genotype, date, well number, and field
% of view number associated with the dataset in the table. 
function [name] = nameDataset(d, i)
    name = [d.virus{i}, '_', num2str(d.date(i)), '_well_', ...
        num2str(d.well_n(i)), '_plate_', d.plate{i}];
end














