function [lb,center] = clusteringParametricMaps(cbf,cbv,tmax,ttp,nImages)
    array = [cbf(:),cbv(:),tmax(:),ttp(:)];
    % distth = 25;
    i = 0;j=0;
    tic
    while(true)

        seed(1) = mean(array(:,1));
        seed(2) = mean(array(:,2));
        seed(3) = mean(array(:,3));
        seed(4) = mean(array(:,4));

        i = i+1;
        while(true)
            j = j+1;

            seedvec = repmat(seed,[size(array,1),1]);

            dist = sum((sqrt((array-seedvec).^2)),2);

            distth = 0.25*max(dist);
            qualified = dist<distth;

            newcbf = array(:,1);
            newcbv = array(:,2);
            newtmax = array(:,3);
            newttp = array(:,4);

            newseed(1) = mean(newcbf(qualified));
            newseed(2) = mean(newcbv(qualified));
            newseed(3) = mean(newtmax(qualified));
            newseed(4) = mean(newttp(qualified));

            if isnan(newseed)
                break;
            end

            if (seed == newseed) | j>10
                j=0;
                array(qualified,:) = [];
                center(i,:) = newseed;
                %             center(2,i) = nnz(qualified);
                break;
            end
            seed = newseed;
        end

        if isempty(array) || i>10
            i = 0;
            break;
        end

    end
    toc
    centers = sqrt(sum((center.^2),2));
    [centers,idx]= sort(centers);
    
    while(true)
        newcenter = diff(centers);
        intercluster = 0.15; %(max(cbv(:)/10));
        a = (newcenter<=intercluster);
        % center(a,:)=[];
        % centers = sqrt(sum((center.^2),2));
        centers(a,:) = [];
        idx(a,:)=[];
        % center(a,:)=0;
        if nnz(a)==0
            break;
        end
    end
    
    center1 = center;
    center =center1(idx,:);
    % [~,idxsort] = sort(centers) ;
    veccbf = repmat(cbf(:),[1,size(center,1)]);
    veccbv = repmat(cbv(:),[1,size(center,1)]);
    vectmax = repmat(tmax(:),[1,size(center,1)]);
    vectttp = repmat(ttp(:),[1,size(center,1)]);
    
    distcbf = (veccbf - repmat(center(:,1)',[numel(cbf),1])).^2;
    distcbv = (veccbv - repmat(center(:,2)',[numel(cbv),1])).^2;
    disttmax = (vectmax - repmat(center(:,3)',[numel(tmax),1])).^2;
    distttp = (vectttp - repmat(center(:,4)',[numel(ttp),1])).^2;
    
    distance = sqrt(distcbf+distcbv+disttmax+distttp);
    [~,label_vector] = min(distance,[],2);
    %lb_tmp = reshape(label_vector,size(cbf));
    
    lb_tmp = reshape(label_vector,[512*512,nImages]);
    lb = cell(1,nImages);
    for t=1:nImages
        lb{1,t} = reshape(lb_tmp(:,t), [512,512]);
    end
    
end
