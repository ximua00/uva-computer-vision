function image_alignment(image1_path, image2_path)
    P = 3;
    N = 10;

    im1 = imread(image1_path);
    im2 = imread(image2_path);
    if length(size(im1)) == 3
        im1 = rgb2gray(im1);
    end
    
    if length(size(im2)) == 3
        im2 = rgb2gray(im2);
    end
    im1 = im2single(im1);
    im2 = im2single(im2);
    [frames1, desc1] = vl_sift(im1);
    [frames2, desc2] = vl_sift(im2);
    
    [matches, ~] = vl_ubcmatch(desc1, desc2);

    inlier_counter_max = 0;
    M_max = 0;
    T_max = 0;
    for n=1:N
        A = zeros(P * 2, 6);
        b = zeros(P * 2, 1);
        
        samples = datasample(matches, P, 2);
        for i=1:P
            first_row = i * 2 - 1;
            second_row = i * 2;
            A(first_row, 5) = 1;
            A(second_row, 6) = 1;
            
            xy = frames1(1:2, samples(1, i));
            b(first_row:second_row) = frames2(1:2, samples(2, i));
            
            A(first_row, 1:2) = xy;
            A(second_row, 3:4) = xy;
        end
        
        transform_matrix = linsolve(A, b);
        
        M = [transform_matrix(1) transform_matrix(2);
             transform_matrix(3) transform_matrix(4)];
        T = [transform_matrix(5); transform_matrix(6)];
        
        inlier_counter = 0;
        for i=1:size(matches, 2)
            xy = M * frames1(1:2, matches(1, i)) + T;
            xy_gt = frames2(1:2, matches(2, i));
            if sqrt(sum((xy - xy_gt) .^2)) <= 10
                inlier_counter = inlier_counter + 1;
            end
        end
        if inlier_counter > inlier_counter_max
            inlier_counter_max = inlier_counter;
            M_max = M;
            T_max = T;
        end
    end
    
    
    [h, w] = size(im1);
    [y, x] = meshgrid(1:h, 1:w);
    y = reshape(y.', 1, []);
    x = reshape(x.', 1, []);
    
    xy_ = int16(ceil([x;y]' * M_max' + repmat(T_max', [length(x), 1])));
    
    x = x';
    y = y';
    
    % A hack to plot an image. Coordinates cannot be negative values
    min_xy_ = min(xy_);
    max_xy_ = max(xy_);
    
    [h, w] = size(im2);
    min_xy = min([min_xy_; 1 1]);
    
    max_xy = max([max_xy_; w h]);
    % Shift
    shift = 1 - min_xy;
    
    w = max_xy(1) - min_xy(1) + 1;
    h = max_xy(2) - min_xy(2) + 1;
    
    % Shifting the first image
    xy_ = xy_ + repmat(shift, [length(xy_), 1]);
    
    im3 = zeros(h, w);

    for i=1:length(xy_)
        im3(xy_(i, 2), xy_(i, 1)) = im1(y(i), x(i));
    end
    
    % Nearest neighbor interpolation
    for i=2:h-1
        for j=2:w-1
            values = [im3(i-1,j-1:j+1) im3(i+1,j-1:j+1) im3(i, j-1) im3(i, j+1)];
            im3(i, j) = mean(values);
        end
    end
    
    %% ALIGNING
    figure;
    imshowpair(im3, im2, 'montage')

    Tr = zeros(3, 3);
    Tr(1:2, 1:2) = M_max';
    Tr(3, 3) = 1;   

    Tr = maketform('affine', Tr);
    tformfwd(T_max, Tr);
    im5 = imtransform(im1, Tr);

    figure;
    imshowpair(im5, im2, 'montage')
    title('With maketform, imtransform');
        
    %% STITCHING
    figure;
    subplot(2, 2, 1);
    imshow(im3);
        
    % Shifting the second image
        
    im4 = zeros(h, w);
    [im2_h, im2_w] = size(im2);
    im4(shift(2) + 1:shift(2) + im2_h,shift(1) + 1:shift(1)+ im2_w) = im2;
        
    subplot(2, 2, 2);
    imshow(im4);

    subplot(2, 2, 3);
    imshowpair(im3, im4);
        
    im3(shift(2) + 1:shift(2) + im2_h,shift(1) + 1:shift(1)+ im2_w) = im2;
        
    subplot(2, 2, 4);
    imshow(im3);
end