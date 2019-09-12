% Plot the traces for all the neurons from one movie
function h = plotSpacedTraces(d, framerate, offset, active_thresh)

% Keep track of where I'm plotting
cur_position = 0;

h = figure;
hold on

for i = 1:size(d, 1)
    
    cur_trace = d.trace(i, :);
   
    cur_position = cur_position - offset;
    
    time = (1:max(size(cur_trace))) ./ framerate;
    plot(time, cur_trace + cur_position, 'k', 'LineWidth', 0.25);
    
    % Plot trace in red for times when the cell is active
    active_trace = cur_trace;
    active_trace(active_trace < active_thresh) = NaN;
    plot(time, active_trace + cur_position, 'r', 'LineWidth', 0.25);
    
%     label_text = num2str(i);
%     figure(traces_fig);
%     text(size(cur_trace, 1)/framerate + offset, cur_position ,label_text);

end

%set(gca, 'visible', 'off');
box off;
set(gca,'xcolor',get(gcf,'color'));
set(gca,'xtick',[]);
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);

% scalebar (1% dF/F, 60 s):
plot([0,60],[0,0],'k');
plot([0,0],[0,0.01],'k');
hold off

end