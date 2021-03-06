function [fr2,matches,desc2, im2] = interest_points(im1, im2, fr1, desc1, debug, teddy, fr2, desc2)
    % run sift with matching features.
    if fr2 == 0
        [fr2, desc2] = vl_sift(im2);
    end

    if teddy
        [matches, ~] = vl_ubcmatch(desc1, desc2, 3);
        distances = sqrt(sum((fr1(1:2, matches(1,:)) - fr2(1:2, matches(2,:))).^2, 1));
        matches = matches(:, distances > 5);
    else
        [matches, ~] = vl_ubcmatch(desc1, desc2, 5);
    end
    
    if debug
        plot_sift(matches, im1, im2, fr1, fr2);
    end
end

function plot_sift(matches, im1, im2, frames1, frames2)
    % I have used the following tutorial, and took inspiration from the code
    % used to generate the tutorial, Found at:
    % https://github.com/vlfeat/vlfeat/blob/master/toolbox/demo/vl_demo_sift_match.m
    % http://www.vlfeat.org/overview/sift.html

    % concatenate the figures
    
    h1 = size(im1, 1);
    h2 = size(im2, 1);
    h = max(h1, h2);
    img1 = zeros(h, size(im1, 2));
    img2 = zeros(h, size(im2, 2));
    
    img1(1:size(im1, 1),1:size(im1, 2)) = im1;
    img2(1:size(im2, 1),1:size(im2, 2)) = im2;
        
    concatenated_figure = cat(2,img1,img2);

    % rescale the x-coordinates for second figure
    X_1 = frames1(1, matches(1,:));
    Y_1 = frames1(2, matches(1,:));

    X_2 = frames2(1, matches(2,:)) + length(img1(1,:));
    Y_2 = frames2(2, matches(2,:));

    % Plot this
    figure;
    imshow(concatenated_figure);
    
    % Create the lines
    hold on;
    lines = plot([X_1; X_2], [Y_1; Y_2]);
    set(lines,'color','r');

    % create the points
    hold on;
    vl_plotframe(frames1(:, matches(1,:)));
    frames2(1,:) = frames2(1,:) + length(img1(1,:));
    hold on;
    vl_plotframe(frames2(:, matches(2,:)));

    %title('Matching Pairs');
end

