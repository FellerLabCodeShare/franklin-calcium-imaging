function [d] = summarizeActivityBouts(d, active_threshold)

d.active_durations = NaN * ones(size(d, 1), size(d.trace, 2));
d.inactive_durations = NaN * ones(size(d, 1), size(d.trace, 2));

    for i = 1:size(d, 1)

        trace = d.trace(i,:); 
        
        active_durations = measureBinaryComponents(trace >= active_threshold);
        d.active_durations(i,1:length(active_durations)) = active_durations;
        
        inactive_durations = measureBinaryComponents(trace < active_threshold);
        d.inactive_durations(i,1:length(inactive_durations)) = inactive_durations;

    end

end 