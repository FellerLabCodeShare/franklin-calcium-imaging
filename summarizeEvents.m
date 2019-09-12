function [d] = summarizeEvents(d, min_prominence, display_findpeaks)

    d.event_frames = NaN * ones(size(d, 1), size(d.trace, 2));
    d.event_fs = NaN * ones(size(d, 1), size(d.trace, 2));

    for i = 1:size(d, 1)
        
        [peaks, locs] = findpeaks(d.trace(i, :), 'MinPeakProminence', min_prominence);
        
        d.event_frames(i, 1:length(locs)) = locs;
        d.event_fs(i, 1:length(peaks)) = peaks; 
        
        % Display output for every hundreth cell 
        if display_findpeaks
            if mod(i, 100) == 0
                figure; 
                findpeaks(d.trace(i, :), 'MinPeakProminence', min_prominence, ...
                    'Annotate','extents');
            end 
        end  
    end 

end 