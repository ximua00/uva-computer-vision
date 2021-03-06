% Quantization & Turning into historgrams
% Authors: Riaan & Minh

function [h] = quantize(centroids, datapoints)

	% ensure the data is normalized
	normalized_data = normalize(datapoints);
	index = zeros(1,size(normalized_data, 2));

	% iterate through the data and find the closest point
    for x = 1:size(normalized_data,2)
	    [~,k] = min(vl_alldist(normalized_data(:,x), centroids));
	    index(1,x) = k;
    end

	% return the histogram
	h = hist(index, size(centroids, 2));% 'Normalization', 'probability');
	h = h./sum(h,2);

end


