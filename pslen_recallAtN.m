function [res, recalls, recalls_pslen]= pslen_recallAtN(searcher, nQueries, isPos, ns, printN, nSample,db,pslen_config)
    if nargin<6, nSample= inf; end
    
    rngState= rng;
    
    if nSample < nQueries
        rng(43);
        toTest= randsample(nQueries, nSample);
    else
        toTest= 1:nQueries;
    end
    
    assert(issorted(ns));
    nTop= max(ns);
    
    recalls= zeros(length(toTest), length(ns));
    recalls_pslen= zeros(length(toTest), length(ns),2);
    printRecalls= zeros(length(toTest),1);

    %% Load variables
    
    iTestSample_Start=pslen_config.iTestSample_Start; 
    startfrom =pslen_config.startfrom; 
    show_output = pslen_config.show_output;  %test the boxes
    dataset_path = pslen_config.datasets_path; 
    save_path = pslen_config.save_path; 
    
    
    evalProg= tic;
    
    
    %% NetVLAD Model

    netID= pslen_config.netID;
    paths = localPaths();
    load( sprintf('%s%s.mat', paths.ourCNNs, netID), 'net' );
    net= relja_simplenn_tidy(net); % potentially upgrate the network to the latest version of NetVLAD / MatConvNet

    %% EDGE BOX
    %load pre-trained edge detection model and set opts (see edgesDemo.m)
    model=load('edges/models/forest/modelBsds'); model=model.model;
    model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;
    % set up opts for edgeBoxes (see edgeBoxes.m)
   
    num_box = 50; % Total = 10 (first one is the full images feature / box)
    Top_boxes = 10; % will be used.
    total_top = 100; %100;0
    inegatif_i = [];

    %% Load PSLEN Model
     if ~(pslen_config.createPslenModel)
        g_mdl =  load(pslen_config.save_pslen_data_mdl);
     end
    %% Start
    for iTestSample= iTestSample_Start:length(toTest)
        
        %Display
        relja_progress(iTestSample, ...
                       length(toTest), ...
                       sprintf('%.4f', mean(printRecalls(1:(iTestSample-1)))), evalProg);
        
     
        iTest= toTest(iTestSample);
        
        [ids ds_pre]= searcher(iTest, nTop); % Main function to find top 100 candidaes
       % ds_pre_max = max(ds_pre); ds_pre_min = min(ds_pre);
       % ds_pre_mean = mean(ds_pre); ds_pre_var = var(ds_pre);
    
        ds = ds_pre - min(ds_pre(:));
       % ds = ds ./ max(ds(:)); 
        
        % if oxford or otherplace datasets, we can get the recall like this
        if(pslen_config.createPslenModel)
            save_path = strcat(pslen_config.pslen_directory,pslen_config.job_net,'_to_',pslen_config.pslen_on,'_',int2str(pslen_config.cropToDim),'_',pslen_config.proj);
            isIgnore= ismember(ids, db.ignoreIDs{iTestSample});
            ids= ids(~isIgnore);
            % making 100 total
            if size(ids,1) < total_top
               differnce_ids =  total_top-size(ids,1);
                for ids_i = 1:differnce_ids
                    ids = [ids ;ids(ids_i,1)];
                    ds_pre = [ds_pre ;ds_pre(ids_i,1)];
                end
            end
            isPos= ismember(ids', db.posIDs{iTestSample});

            gt_top = isPos';
        else
            gt_top = isPos(iTest, ids);
        end
       
      %  thisRecall_ori= cumsum(logical(isPos(iTest, ids)) ) > 0; % yahan se get karta hai %db.cp (close position)
        %ds_pre_gt = gt_top(isPos(iTest, ids));
        gt_top_ids = int8(gt_top/10);
        %gt_top_ids(gt_top_ids>10) = 0;
        
        
        %% Leo START
                
        qimg_path = strcat(dataset_path,'/',pslen_config.query_folder, '/', db.qImageFns{iTestSample, 1});  
        q_img = strcat(save_path,'/', db.qImageFns{iTestSample, 1});  
        q_feat = strrep(q_img,'.jpg','.mat');

            
        if exist(q_feat, 'file')
             x_q_feat = load(q_feat);
             x_q_feat_all(iTestSample) = struct ('x_q_feat', x_q_feat); 
        else

            q_feat = leo_estimate_box_features(qimg_path,model,db,q_feat,net,num_box,total_top,dataset_path,ids,iTestSample);
            x_q_feat = load(q_feat);

        end

        total_top = size(ids,1); %100;0
    

%%        
        SLEN_top = zeros(total_top,2); 
       
        exp_ds_pre = exp(-1.*ds_pre);
        ds_pre_diff = diff(ds_pre);
        ds_pre_diff = [ds_pre_diff; 0];
        exp_ds_pre_sum = sum(exp_ds_pre);
        prob_q_db = exp_ds_pre/exp_ds_pre_sum;
        x_q_feat_ds_all = [];
        min_ds_pre_all = [];

        % figure;
            
        for i=startfrom:total_top   
            x_q_feat_ds= x_q_feat.ds_all_file(i).ds_all_full; % 51x50
            x_q_feat_ds_all = [x_q_feat_ds_all ;x_q_feat_ds];  % 5100 x 50

        end
        ds_box_all_sum = sum(x_q_feat_ds_all(:));
        
    
        
        for i=startfrom:total_top 
 
            
           %Single File Load
           x_q_feat_ds_all = x_q_feat.ds_all_file(i).ds_all_full; %51*50         first match ka box
           x_q_feat_box_q =  x_q_feat.q_bbox;                       %51*5
           x_q_feat_box_db = x_q_feat.db_bbox_file(i).bboxdb;       % 51*5

           
           x_q_feat_ds_all_exp = exp(-1.*x_q_feat_ds_all); % jj first match
            
           sum_ds_all_Prob = sum(x_q_feat_ds_all_exp(:));
           
           
           % excluding the top
           
           ds_all = x_q_feat_ds_all(2:end,:);  
           [ds_all_sort ds_all_sort_index] = sort(ds_all);
          
            diff2_ds_all = diff(diff(ds_all));
            diff2_ds_all_less = diff2_ds_all;

            
            ds_all_less = x_q_feat_ds_all-max(ds_pre(:));

            s=sign(ds_all_less); 
            
            inegatif=sum(s(:)==-1);

            S_less = s; S_less(S_less>0) = 0; 
            S_less = abs(S_less).*x_q_feat_ds_all; 
         
            
            D_diff = ds_pre(i,1); 
            
            exp_relative_diff = exp(-1.*ds_pre_diff(i,1)); %*exp_related_Box_dis;
                           
           [row,col] = size(x_q_feat_ds_all);    
            
           box_var_db = [];
            
           for iii = 1: col
                for jjj = 1:row 

                    %Query -> Row and DB -> DB1 DB2 DB3 DB4 DB5 DB6 DB7
                    %DB8
                    %

                    %related_Box_dis_top = x_q_feat_ds_all(1,col(jjj));


                    related_Box_dis = x_q_feat_ds_all(jjj,iii);   % 51X51
                  

                    related_Box_db = iii;
                    related_Box_q = jjj;
                   % related_Box_q = ds_all_sort_index(row(jjj),col(jjj));


                    bb_q = x_q_feat_box_q(related_Box_q,1:4);
                    bb_db = x_q_feat_box_db(related_Box_db,1:4); % Fix sized, so es ko 50 waly ki zarorat nai hai                      

                    q_size = x_q_feat_box_q(1,3)*(x_q_feat_box_q(1,4));  % wrong size, 3 se multiply howa howa hai
                    db_size = x_q_feat_box_db(1,3)*(x_q_feat_box_db(1,4));

                    q_width_height = (bb_q(1,3)*bb_q(1,4))/(q_size);
                    db_width_height = (bb_db(1,3)*bb_db(1,4))/(db_size);

                    exp_q_width_height = exp(-1.*(1-q_width_height));
                    exp_db_width_height = exp(-1.*(1-db_width_height));


                    sum_distance = ds_pre(1,1)+related_Box_dis;
                    exp_sum_distance = exp(-1.*sum_distance); %*exp_related_Box_dis;

                    ds_all_box(related_Box_q,related_Box_db) = 10*exp_relative_diff*exp_sum_distance*exp_q_width_height*exp_db_width_height;

                end
           end
                
         
           ds_all_box_sorted = zeros(num_box,num_box);
           S_less_Nr_sorted = zeros(num_box,num_box);
 
           for jj = 1: num_box
               for ii = 1 : num_box
                    ii_index = ds_all_sort_index(ii,jj);
                    ds_all_box_sorted(ii,jj) = ds_all_box(ii_index+1,jj); %51*51
                    ds_all_less_sorted(ii,jj) = ds_all_less(ii_index+1,jj);
                    S_less_sorted(ii,jj) = S_less(ii_index+1,jj);
               end
           end
           
           ds_all_s_less = ds_all_box_sorted.*ds_all_less_sorted; 
                            

            S1 = S_less_sorted; 
            S1_mean = sum(S1(:))/nnz(S1);
            S1(S1>S1_mean) = 0;
            S2 = S1; 
            S2_mean = sum(S2(:))/nnz(S2);
            S2(S2>S2_mean) = 0;
            S3 = S2; 
            S3_mean = sum(S3(:))/nnz(S3);
            S3(S3>S3_mean) = 0;
            
            
            S1_logical = logical(S1);
%             ds_all_s_less_s1 = S1_logical.*ds_all_s_less;
            ds_all_s_less_s1_sub = ds_all_s_less(1:Top_boxes,1:Top_boxes);
            
            min_ds_all = S_less_sorted(1:Top_boxes,1:Top_boxes);
            if (nnz(min_ds_all) > 0)
                min_ds_all = min(min_ds_all(min_ds_all > 0));
            else
                min_ds_all = 0;
            end
            prob_ds_pre_sum = exp_ds_pre(i,1)/exp_ds_pre_sum;
            prob_ds_pre_sum = exp(-1*min_ds_all)*prob_ds_pre_sum;

            Pslen_mat = prob_ds_pre_sum*ds_all_s_less_s1_sub;
            
         

            crf_h = x_q_feat_ds_all(1,1:10);%double(pslen_ds_all(1,:));
            crf_X = Pslen_mat;%double(pslen_ds_all(2:11,:));
            crf_pre = ds_pre(i,1);
         
             if ~(pslen_config.createPslenModel)
                 crf_y = int8(logical(gt_top_ids(i,1)))+1;
                 XX = crf_X';
                 XX = reshape(XX,1,[]);
                 pslen_pridict = [crf_pre crf_h XX];



                %store ds_pre
                ds_new_top(i,1) = ds_pre(i,1);
                
                D_diff_predict = predict(g_mdl.mdls{1},pslen_pridict);
                ds_new_top(i,2) = abs(D_diff/D_diff_predict);
                D_diff_predict = predict(g_mdl.mdls{6},pslen_pridict);
                ds_new_top(i,3) = abs(D_diff/D_diff_predict);
                

                
                Pslen_table = [];

                ds_all = [];
             else
                 crf_y = int8(gt_top(i,1))+1;         %  for PARIS
                 crf_data = struct ('Y', crf_y,'H', crf_h,'X', crf_X, 'pre', crf_pre); 
                 data(:,i+((iTestSample-1)*100)) = crf_data;
             end
        
        end
   
        
        if ~(pslen_config.createPslenModel)
            
           for j = 1:size(ds_new_top,2)
    
                [C c_i] = sortrows(ds_new_top(:,j));
                ids_new = ids;
               % inegatifss = inegatif_i;
                for i=1:total_top
                    ids_new(i,1) = ids(c_i(i,1));
                   % inegatifss(i,1) = inegatif_i(c_i(i,1));
                end
            %     if show_output == 3
            % 
            %             subplot(2,6,1); imshow(imread(char(qimg_path))); %q_img
            %             db_imgo1 = strcat(dataset_path,'/images/', db.dbImageFns{ids(1,1),1});  
            %             db_imgo2 = strcat(dataset_path,'/images/', db.dbImageFns{ids(2,1),1});  
            %             db_imgo3 = strcat(dataset_path,'/images/', db.dbImageFns{ids(3,1),1});  
            %             db_imgo4 = strcat(dataset_path,'/images/', db.dbImageFns{ids(4,1),1});  
            %             db_imgo5 = strcat(dataset_path,'/images/', db.dbImageFns{ids(5,1),1});  
            %             db_img1 = strcat(dataset_path,'/images/', db.dbImageFns{idss(1,1),1});  
            %             db_img2 = strcat(dataset_path,'/images/', db.dbImageFns{idss(2,1),1});  
            %             db_img3 = strcat(dataset_path,'/images/', db.dbImageFns{idss(3,1),1});
            %             db_img4 = strcat(dataset_path,'/images/', db.dbImageFns{idss(4,1),1});
            %             db_img5 = strcat(dataset_path,'/images/', db.dbImageFns{idss(5,1),1});
            % 
            %             subplot(2,6,2); imshow(imread(char(db_imgo1))); %
            %             aa = strcat(string(ds_pre(1,1)));title(aa)
            % 
            %             subplot(2,6,3); imshow(imread(char(db_imgo2))); %
            %             aa = strcat(string(ds_pre(2,1)));title(aa)
            % 
            %             subplot(2,6,4); imshow(imread(char(db_imgo3))); %
            %             aa = strcat(string(ds_pre(3,1)));title(aa)
            % 
            %             subplot(2,6,5); imshow(imread(char(db_imgo4))); %
            %             aa = strcat(string(ds_pre(4,1)));title(aa)
            % 
            %             subplot(2,6,6); imshow(imread(char(db_imgo5))); %
            %             aa = strcat(string(ds_pre(5,1)));title(aa)
            % 
            % 
            %             subplot(2,6,8); imshow(imread(char(db_img1))); %
            %             aa = strcat(string(ds_new_top(1,1)), '->', string(prob_q_db(1,1)));title(aa)
            %             subplot(2,6,9); imshow(imread(char(db_img2))); %
            %             aa = strcat(string(ds_new_top(2,1)), '->', string(prob_q_db(1,1)));title(aa)
            %             subplot(2,6,10); imshow(imread(char(db_img3))); %
            %             aa = strcat(string(ds_new_top(3,1)), '->', string(prob_q_db(1,1)));title(aa)
            %             subplot(2,6,11); imshow(imread(char(db_img4))); %
            %             aa = strcat(string(ds_new_top(4,1)), '->', string(prob_q_db(1,1)));title(aa)
            %             subplot(2,6,12); imshow(imread(char(db_img5))); %
            %             aa = strcat(string(ds_new_top(5,1)), '->', string(prob_q_db(1,1)));title(aa)
            % 
            %             %fprintf( '==>> %f %f %f %f %f \n',c_i(1,1), c_i(2,1),c_i(3,1), c_i(4,1) ,c_i(5,1));
            % 
            %      end

               numReturned= length(ids);
               assert(numReturned<=nTop); % if your searcher returns fewer, it's your fault

               thisRecall= cumsum( isPos(iTest, ids_new) ) > 0; % yahan se get karta hai %db.cp (close position)
               if j == 1
                    recalls(iTestSample, :)= thisRecall( min(ns, numReturned) );
               else
                    recalls_pslen(iTestSample,:, j-1)= thisRecall( min(ns, numReturned) );
               end

              printRecalls(iTestSample)= thisRecall(printN);
            end
           
        end
    end
    
    t= toc(evalProg);

    if (pslen_config.createPslenModel)
        save(pslen_config.save_pslen_data,'data');
        res = [];
        fprintf( 'GT data is saved. \n')
    else
        res= mean(printRecalls);
        relja_display('\n\trec@%d= %.4f, time= %.4f s, avgTime= %.4f ms\n', printN, res, t, t*1000/length(toTest));
        relja_display('%03d %.4f\n', [ns(:), mean(recalls,1)']');
        relja_display('%03d %.4f\n', [ns(:), mean(recalls,1)']');
        rng(rngState);
    end
end

function [mat_boxes,im, edge_image, hyt, wyd] = img_Bbox(db_img,model)
    im= vl_imreadjpeg({char(db_img)},'numThreads', 12); 
    I = uint8(im{1,1});
    [bbox, E] =edgeBoxes(I,model);
    [hyt, wyd] = size(im{1,1});
    edge_image = uint8(E * 255);
    bboxes=[];
    gt=[111	98	25	101];

    b_size = size(bbox,1); 
    for ii=1:b_size
         bb=bbox(ii,:);
         square = bb(3)*bb(4);
         if square <2*gt(3)*gt(4)
            bboxes=[bbox;bb];
         end
    end

    mat_boxes = uint8(bboxes); 
end

function img = draw_boxx(I,bb)

    %img = insertShape(I,'Rectangle',bb,'LineWidth',3);
    %drawRectangle(image, Xmin, Ymin, width, height)
    img = drawRectangle(I, bb(2), bb(1), bb(4), bb(3));

end