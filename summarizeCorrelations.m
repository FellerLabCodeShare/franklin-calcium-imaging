function [d] = summarizeCorrelations(d)
% For each cell, compute the pairwise correlations with all other cells in
% the movie 

    for i = 1:size(d,1) 

        n_cells = sum(~isnan(d.correlation(i, :))); 
        d.mean_correlation(i, :) = (nansum(d.correlation(i, :)) - 1) ./ (n_cells - 1); 

    end 

end 