function [imOut, Gd] = gaussianDer(image_path, G, sigma)
    img = im2double(imread(image_path));

    [w, ~] = size(G);
    Gd = zeros(w, 1);
    radius = floor(w / 2);
    for x=1:w
        Gd(x, 1) = - (x - radius - 1) / (sigma^2) * G(x, 1);
    end
    
    [h, w, d] = size(img);
    imOut = zeros(h, w, d);
    for x=radius+1:w-radius
        for y=1:h
            for z=1:d
                imOut(y, x, z) = sum(Gd' .* img(y, x-radius:x+radius, z));
            end
        end
    end
    
    %% Multiplying with 50 to increase intensity
    plot = false;
    if plot
        imshow(30 * im2double(imOut));
    end
end