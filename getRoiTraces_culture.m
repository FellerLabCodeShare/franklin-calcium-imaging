% Takes in imagej rois in a struct + a movie (3d array) and spits out an
% n rois x n frames array of traces, along with an n rois x 1 array of f0 values
function [traces, f0s, rois_mask] = getRoiTraces_culture(f, f0_img, rois)
    rois_mask = zeros(size(f,1), size(f,2)); 
    traces = cell(size(rois, 2), 1); 
    f0s = zeros(1, size(rois, 2));
    for i = 1:size(rois, 2)
        [trace, f0, roi_mask] = getTrace(f, f0_img, rois{i}); 
        f0s(i) = f0; 
        traces{i} = trace(:);
        rois_mask = rois_mask + i.* roi_mask;
    end
end

function [trace, mean_f0, roi_mask] = getTrace(f, f0_img, roi)

    % Determine what type of ROI we're trying to read and convert to a mask
    switch roi.strType
        case 'Oval'
            roi_mask = ovalRoiMask(f, roi); 
        case 'Freehand'
            roi_mask = freeHandRoiMask(f, roi);
        otherwise
            error(['Encountered unknown roi type: ', roi.strType]); 
    end
    
    roi_size = sum(sum(roi_mask)); 
    roi_mask_mat = repmat(roi_mask, 1, 1, size(f, 3));
    %f(isnan(f)) = 0; 
    %roi_mask_mat(isnan(roi_mask_mat)) = 0; 
    
    % Convert roi_mask_mat to the same type as the f movie
    switch class(f)
        case 'uint8'
            roi_mask_mat = uint8(roi_mask_mat);
        case 'uint16'
            roi_mask_mat = uint16(roi_mask_mat);
        case 'double'
            roi_mask_mat = double(roi_mask_mat);
        otherwise
            error(['Movie was in an un-handled format: ', class(f)]); 
    end 
    
    trace = nansum(nansum(roi_mask_mat .* f)) ./ roi_size; 
    mean_f0 = nansum(nansum(roi_mask .* f0_img)) / roi_size; 

end

function [mask] = freeHandRoiMask(f, roi)
    [m, n, ~] = size(f);
    xs = roi.mnCoordinates(:,1);
    ys = roi.mnCoordinates(:,2); 
    mask = poly2mask(xs, ys, m, n);
end

function [mask] = ovalRoiMask(f, roi)

    top = roi.vnRectBounds(1); left = roi.vnRectBounds(2); bottom = roi.vnRectBounds(3); right = roi.vnRectBounds(4);
    W = [left, left, right, right];
    H = [top, bottom, bottom, top];
    mask = poly2mask(W, H, size(f, 1), size(f, 2)); 
    for y = left:right
        for x = top:bottom
            if ~inOval(x, y, left, right, top, bottom) && x <= size(f, 1) && y <= size(f, 2)
                if inFOV(x, y, size(f, 1), size(f, 2))
                    mask(x, y) = 0; 
                end 
            end
        end
    end 
end

function [in_oval] = inOval(x, y, left, right, top, bottom)

    a = (right - left) / 2;
    b = (bottom - top) / 2;
    xm = top + b;
    ym = left + a;
    in_oval = ((x - xm)^2 / b^2 + (y - ym)^2 / a^2) < 1; 

end

function infov = inFOV(x, y, h, w)
    infov = x > 0 & x < h & y > 0 & y < w;
end






