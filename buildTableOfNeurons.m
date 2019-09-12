function [d] = buildTableOfNeurons(g_name, root_directory, max_movie_frames, max_neurons)
% Given a spreadsheet of experiments, produce a data table with one row for each neuron 

    % Set up an empty array to hold the Neuron objects
    neurons = []; 
    
    % Set up an empty array to keep track of which rows of the guide table
    % correspond to each neuron 
    guide_rows = []; 
    
    % Load the data guide spreadsheet
    g = readtable(g_name); 
    
    % Manually exclude data
    g = g(logical(g.include), :); 
    
    % Initialize an array to store correlation matrices
    Correlations = cell(1, length(g.data_name)); 
    
    % Intiailize a counter to uniquely label neurons
    cur_neuron_idx = 1; 

    % For each row of the data guide spreadsheet... 
    for r = 1:length(g.data_name)
        
        % Start at the root directory 
        cd(root_directory); 
    
        % Load the FOV object 
        cd(g.path{r});
        F = load([g.data_name{r}, '.mat']);
        
        % For whatever reason, matlab loads retina objects as structs with
        % a '.R' field. Go in to the struct and get out the retina object. 
        if isstruct(F)
            field_names = fields(F);
            field_name = field_names{1};
            F = F.(field_name);
        end 
        
        % Neuron IDs for this FOV
        ids = F.getNeuronIDList(); 
        
         % Make sure number of neurons is not over max_neurons 
        if length(ids) > max_neurons
            warning('Neurons in the FOV exceeded the max_neurons parameter supplied by the user');
        end 
        
        % Store pairwise correlation matrix
        movie_names = F.getFullMovieList(); 
        Correlations{r} = corrcoef(F.getTraces(ids, movie_names{1})'); 
        
        % For each Neuron object...
        for i = 1:length(ids) 
        
            % Add the Neuron to the array of Neurons 
            neurons = [neurons, F.getNeuron(ids{i})];
            
            % Keep track of which row of the data guide table it came from. 
            guide_rows = [guide_rows, r];
            
        end
    end 
    
    % Create the table with pre-allocated columns
    var_names = {'neuron_id', 'virus', 'date', 'well_n', 'plate', 'movie_name',... 
        'data_name', 'f0', 'neuron_object'};
    var_types = {'double', 'string', 'double', 'double', 'string', 'string', 'string', 'double', 'neuron'};
    sz = [length(neurons) length(var_names)];
    d = table('Size', sz, 'VariableTypes', var_types, 'VariableNames', var_names);
    
    % Pre-allocate the data column that holds the fluorescence trace and
    % pairwise correlations for each neuron 
    d.trace = NaN * ones(length(neurons), max_movie_frames); 
    d.correlation = NaN * ones(length(neurons), max_neurons); 
    
    % Put all the neurons in the array 
    d.neuron_object = neurons'; 
    
    % Keep track of the index of the neuron within its movie
    neuron_idx = 1; 
    
    % For each Neuron, fill in a row of the table 
    for i = 1:length(neurons)
        
        % Is this a new movie? If so, restart neuron indexing
        if guide_rows(i) ~= r
            neuron_idx = 1; 
        end
        
        n = neurons(i); 
        r = guide_rows(i); 
        
        % Experimental metadata
        d.neuron_id(i) = cur_neuron_idx; % generate a unique neuron id 
        cur_neuron_idx = cur_neuron_idx + 1; 
        d.virus{i} = g.virus{r}; 
        d.date(i) = g.date(r);
        d.well_n(i) = g.well_n(r);
        d.plate{i} = g.plate{r};
        d.movie_name{i} = g.movie_name{r};
        d.data_name{i} = g.data_name{r};
        d.f0(i) = n.getF0(g.movie_name{r}); 
       
        % The fluorescence trace for this neuron 
        trace = n.getTrace(g.movie_name{r});
        d.trace(i, 1:length(trace)) = trace;
        
        % The pairwise correlations for this neuron
        d.correlation(i, 1:size(Correlations{r}, 2)) = Correlations{r}(neuron_idx, :); 
        neuron_idx = neuron_idx + 1; 
        
    end 
    
end 