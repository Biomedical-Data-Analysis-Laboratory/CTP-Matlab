close all
colorbarPointY = 436;
threspixelval = 100;

patients = getPatientsForExtraction_080520();

for patient = patients
    regions = [patient.penumbraregion, patient.coreregion];

    for region = regions
        if ~isfolder(region.savepath)
            mkdir(region.savepath);
        end

        for imgname = dir(region.filepath)'
            if ~strcmp(imgname.name,".") && ~strcmp(imgname.name, "..")
                img = imread(strcat(imgname.folder, "/", imgname.name));
                if strcmp(patient.location, "right")
                    img = imcrop(img, [0,0,512,512]);
                elseif strcmp(patient.location, "left")
                    space = size(img,2);
                    img = imcrop(img, [space-512,0,512,512]);
                end

                new_img = zeros(512);

                R = img(:,:,1);
                G = img(:,:,2);
                B = img(:,:,3);
                white_annot = (R>threspixelval & G >threspixelval & B>threspixelval);
                white_annot(:,colorbarPointY:end) = 0; 

                for r_idx = 1:size(white_annot,1)-1
                    row = white_annot(r_idx,:);
                    for pidx = 1:size(row,2)-1
                        pixel = row(pidx);

                        d = [ 1 0; -1 0; 1 1; 0 1; -1 1; 1 -1; 0 -1; -1 -1]; 
                        loc =[r_idx pidx];
                        neighbors = d+repmat(loc,[8 1]);
                        % remove rows with zeros
                        a = find(neighbors(:,1)==0);
                        b = find(neighbors(:,2)==0);
                        neighbors(union(a,b),:) = [];
                        sumneighborspixels = 0;
                        for n = neighbors'
                            sumneighborspixels = sumneighborspixels + white_annot(n(1),n(2));
                        end

                        if pixel==0 && sumneighborspixels>1
                            new_img(r_idx, pidx) = 1;
                        elseif pixel==1
                            new_img(r_idx, pidx) = pixel;
                        end
                    end
                end

                new_img = bwareaopen(imfill(new_img,8,'holes'),300);
                splitname = split(imgname.name,".");
                savename = strcat(patient.prefix, patient.ID, "_", splitname(1), "_", region.id, ".png");
                imwrite(new_img, strcat(region.savepath,savename));
            end
        end
    end
end