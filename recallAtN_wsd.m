function [res, recalls, allrecalls_m]= recallAtN_wsd(searcher, nQueries, isPos, ns, printN, nSample,db,m_config)
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
    recalls_m= zeros(length(toTest), length(ns),2);
    printRecalls= zeros(length(toTest),1);

    %% Load variables
    
    iTestSample_Start=m_config.iTestSample_Start; 
    startfrom =m_config.startfrom; 
    show_output = m_config.show_output;  %test the boxes
    dataset_path = m_config.datasets_path; 
    save_path = m_config.save_path; 
    save_m_on = m_config.save_m_on;
    m_limit = m_config.m_limit;
    m_alpha = m_config.m_alpha;
    
    evalProg= tic;
    
    
    %% NetVLAD Model

    netID= m_config.netID;
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
    
    if show_output
        fig1 = figure;
        pos_fig1 = [0 0 1500 320];
        set(fig1,'Position',pos_fig1)
    end
    
    %% Load m Model
     if ~(m_config.create_Model)
        g_mdl =  load(m_config.save_m_data_mdl);
     end
    %% Start
    for iTestSample= iTestSample_Start:length(toTest)
        
        %Display
        relja_progress(iTestSample, ...
                       length(toTest), ...
                       sprintf('%.4f', mean(printRecalls(1:(iTestSample-1)))), evalProg);
        
     
        iTest= toTest(iTestSample);
        
        [ids, ds_pre]= searcher(iTest, nTop); % Main function to find top 100 candidaes
     
    
        ds = ds_pre - min(ds_pre(:));
        
        % if oxford or otherplace datasets, we can get the recall like this
        if(m_config.create_Model)
            %working for TokyoTM    
            gt_top = logical(isPos(iTest, ids));

            q_img = strcat(save_m_on,'/', db.qImageFns{iTestSample, 1});  
        else
            
            q_img = strcat(save_path,'/', db.qImageFns{iTestSample, 1});  
        end
       
        
        %% Leo START
                
        qimg_path = strcat(dataset_path,m_config.query_folder, '/', db.qImageFns{iTestSample, 1});  
        
        if show_output
            qq_img = imread(qimg_path);
            p_margin = 0.002;
            subplot_tight(2, 7, [1 2 8 9], p_margin);
            imshow(qq_img); %
            ntitle(['Query Image'],...
                'location','south',...
                'FontSize',10,...
                'backgroundcolor','w');
        end
        
        
        
        q_feat = strrep(q_img,'.jpg','.mat');

            
        if exist(q_feat, 'file')
             x_q_feat = load(q_feat);
             x_q_feat_all(iTestSample) = struct ('x_q_feat', x_q_feat); 
        else

            q_feat = estimate_box_features_wsd(qimg_path,model,db,q_feat,net,num_box,total_top,dataset_path,ids,iTestSample);
            x_q_feat = load(q_feat);

        end

        total_top = size(ids,1); %100;0
    

%%        
        SLEN_top = zeros(total_top,2); 
       
        exp_ds_pre = exp(-1.*ds_pre);
        ds_pre_diff = diff(ds_pre);
        ds_pre_diff = [0 ; ds_pre_diff ];
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
            current_diff = ds_pre_diff(i,1); 
            exp_relative_diff = exp(-1.*ds_pre_diff(i,1)); %*exp_related_Box_dis;
                           
           [row,col] = size(x_q_feat_ds_all);    
            
           box_var_db = [];
            
           for iii = 1: col
                for jjj = 1:row 

                    %Query -> Row and DB -> DB1 DB2 DB3 DB4 DB5 DB6 DB7
                    %DB8
                    %


                    related_Box_dis = x_q_feat_ds_all(jjj,iii);   % 51X51
                  

                    related_Box_db = iii;
                    related_Box_q = jjj;

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
            ds_all_s_less_s1_sub = ds_all_s_less(1:Top_boxes,1:Top_boxes);
            
            min_ds_all = S_less_sorted(1:Top_boxes,1:Top_boxes);
            if (nnz(min_ds_all) > 0)
                min_ds_all = min(min_ds_all(min_ds_all > 0));
            else
                min_ds_all = 0;
            end
            prob_ds_pre_sum = exp_ds_pre(i,1)/exp_ds_pre_sum;
            prob_ds_pre_sum = exp(-1*min_ds_all)*prob_ds_pre_sum;

            m_mat = prob_ds_pre_sum*ds_all_s_less_s1_sub;
            mean_min_top = exp(-1.*mean(x_q_feat_ds_all(1,1:10))); 
         

            crf_h = [current_diff x_q_feat_ds_all(1,1:10)];%double(m_ds_all(1,:));
            crf_X = m_mat;%double(m_ds_all(2:11,:));
            crf_pre = ds_pre(i,1);
         
             if ~(m_config.create_Model)
                 XX = crf_X';
                 XX = reshape(XX,1,[]);
                 m_pridict = [crf_pre crf_h XX];

                %store ds_pre
              ds_new_top(i,1) = D_diff;
                
              D_diff_predict = predict(g_mdl.mdls{1},m_pridict);
              ds_new_top(i,2) =  abs(D_diff-m_alpha*log(D_diff_predict));   
               
              D_diff_predict = predict(g_mdl.mdls{2},m_pridict);
              ds_new_top(i,3) =  abs(D_diff-m_alpha*log(D_diff_predict));   
       
                        
              m_table = [];
              ds_all = [];
             else
                 crf_y = int8(gt_top(i,1))+1;         %  for PARIS
                 crf_data = struct ('Y', crf_y,'H', crf_h,'X', crf_X, 'pre', crf_pre); 
                 data(:,i+((iTestSample-1)*100)) = crf_data;
             end
        
        end
   
        display_thumb = [];
        if ~(m_config.create_Model)
            
           for j = 1:size(ds_new_top,2)
    
                [C c_i] = sortrows(ds_new_top(:,j));
                ids_new = ids;
                for i=1:total_top
                    ids_new(i,1) = ids(c_i(i,1));
                end
            

               numReturned= length(ids);
               assert(numReturned<=nTop); % if your searcher returns fewer, it's your fault
               
               gt_top = logical(isPos(iTest, ids_new));

               thisRecall= cumsum( isPos(iTest, ids_new) ) > 0; % yahan se get karta hai %db.cp (close position)
               if j == 1
                    recalls(iTestSample, :)= thisRecall( min(ns, numReturned) );
               else
                    recalls_m(iTestSample,:, j-1)= thisRecall( min(ns, numReturned) );
               end

              printRecalls(iTestSample)= thisRecall(printN);
              display_thumb = [display_thumb ids_new(1:5,1) gt_top(1:5,1)];
              
           end
           
           allrecalls_pslen= recalls_m;
           allrecalls_m= [mean(allrecalls_pslen(:,:,1),1 )' mean(allrecalls_pslen(:,:,2),1 )'];
           
           if show_output
              
               for j = 1:5
                    %netvlad = imread(netvlat_img(j,1));
                    netvlad = imread(strcat(dataset_path,'images/',db.dbImageFns{display_thumb(j,1),1}));

                    if(display_thumb(j,2) == 1)
                        image_n = addborder(netvlad, 10, [0,255,0], 'outer'); 
                    else
                        image_n = addborder(netvlad, 10, [255,0,0], 'outer'); 
                    end
                    subplot_tight(2, 7, j+2, p_margin);
                    imshow(image_n);

                    ntitle(['NetVLAD Recall @ ',num2str(j)],...
                    'location','south',...
                    'FontSize',10,...
                    'backgroundcolor','w');

                    maqbool = imread(strcat(dataset_path,'images/', db.dbImageFns{display_thumb(j,5),1}));
                    if(display_thumb(j,6) == 1)
                        image_m = addborder(maqbool, 10, [0,255,0], 'outer'); 
                    else
                        image_m = addborder(maqbool, 10, [255,0,0], 'outer'); 
                    end
                    subplot_tight(2, 7, j+9, p_margin);
                    imshow(image_m);

                    ntitle(['MAQBOOL Recall @ ',num2str(j)],...
                    'location','south',...
                    'FontSize',10,...
                    'backgroundcolor','w');

                end

               
           end
           
        else
            allrecalls_m = [];
        end
        if iTestSample == m_limit && m_config.create_Model
            break;
        end
    end
    
    t= toc(evalProg);

    if (m_config.create_Model)
        save(m_config.save_m_data,'data');
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