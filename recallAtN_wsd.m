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
    dataset_path = strcat(m_config.datasets_path,m_config.query_folder); 
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
    data_test = [];
    
    
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
        
        q_data_test = strcat(m_config.save_m_data_test,'/', db.qImageFns{iTestSample, 1});  
        q_data_test = strrep(q_data_test,'.jpg','.mat');

        if exist(q_data_test, 'file')
            q_data_test_exist = true;
            load(q_data_test); % load D_diff_predict_50 and D_diff_predict_100

        else
            %if you dont want to compute, you can download from NETVLAD's project page.
             % print_level_wsd(m_config.save_m_data_test,3); % Download pre-computed files    
            q_data_test_exist = false;
        end
            iTest= toTest(iTestSample);
            [ids, ds_pre]= searcher(iTest, nTop); % Main function to find top 100 candidaes
            ds = ds_pre - min(ds_pre(:));

         
            % if oxford or otherplace datasets, we can get the recall like this
            if(m_config.create_Model)
                %working for TokyoTM    
                gt_top = logical(isPos(iTest, ids));

                q_img = strcat(save_m_on,'/', db.qImageFns{iTestSample, 1});
                zip_folder = save_m_on;
            else

                q_img = strcat(save_path,'/', db.qImageFns{iTestSample, 1});  
                zip_folder = save_path;
            end


            %% Leo START

            qimg_path = strcat(dataset_path, '/', db.qImageFns{iTestSample, 1});  

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


        if ~q_data_test_exist
            q_feat = strrep(q_img,'.jpg','.mat');


            if exist(q_feat, 'file')
                 x_q_feat = load(q_feat);
                 x_q_feat_all(iTestSample) = struct ('x_q_feat', x_q_feat); 
            else
                %if you dont want to compute, you can download from NETVLAD's project page.
               %  print_level_wsd(zip_folder,4); % Download pre-computed files    
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
            C_j_nn = [];
            min_ds_pre_all = [];

            % figure;

            for i=startfrom:total_top   
                x_q_feat_ds= x_q_feat.ds_all_file(i).ds_all_full; % 51x50
                C_j_nn = [C_j_nn ;x_q_feat_ds];  % 5100 x 50

            end
            ds_box_all_sum = sum(C_j_nn(:));
        
        end
        
        for i=startfrom:total_top 
 
           if ~q_data_test_exist 
               %Single File Load
               C_j_nn = x_q_feat.ds_all_file(i).ds_all_full; %51*50         first match ka box
               x_q_feat_box_q =  x_q_feat.q_bbox;                       %51*5
               x_q_feat_box_db = x_q_feat.db_bbox_file(i).bboxdb;       % 51*5


               C_j_nn_exp = exp(-1.*C_j_nn); % jj first match

               % excluding the top

               C_n_n = C_j_nn(2:end,:);  
               [C_n_n_sort C_n_n_sort_index] = sort(C_n_n);

                diff2_C_n_n = diff(diff(C_n_n));
                diff2_C_j_f = diff2_C_n_n;


                C_j_f = C_j_nn-max(ds_pre(:));  % d_c^max

                s=sign(C_j_f); 

                inegatif=sum(s(:)==-1);

                D_j = s; D_j(D_j>0) = 0; 
                C_j_nn = abs(D_j).*C_j_nn; 


                D_diff = ds_pre(i,1); 
                current_diff = ds_pre_diff(i,1); 
                exp_R = exp(-1.*ds_pre_diff(i,1)); %*exp_c_xy_j;

               [row,col] = size(C_j_nn);    

               box_var_db = [];

               for iii = 1: col
                    for jjj = 1:row 

                        %Query -> Row and DB -> DB1 DB2 DB3 DB4 DB5 DB6 DB7
                        %DB8
                        %


                        c_xy_j = C_j_nn(jjj,iii);   % 51X51


                        related_Box_db = iii;
                        related_Box_q = jjj;

                        bb_q = x_q_feat_box_q(related_Box_q,1:4);
                        bb_db = x_q_feat_box_db(related_Box_db,1:4); % Fix sized, so es ko 50 waly ki zarorat nai hai                      

                        q_size = x_q_feat_box_q(1,3)*(x_q_feat_box_q(1,4));  % wrong size, 3 se multiply howa howa hai
                        db_size = x_q_feat_box_db(1,3)*(x_q_feat_box_db(1,4));

                        q_width_height = (bb_q(1,3)*bb_q(1,4))/(q_size);
                        db_width_height = (bb_db(1,3)*bb_db(1,4))/(db_size);

                        exp_P_b_q = exp(-1.*(1-q_width_height));
                        exp_P_b_c = exp(-1.*(1-db_width_height));


                        d_xy_j = ds_pre(1,1)+c_xy_j;
                        exp_d_xy_j = exp(-1.*d_xy_j); %*exp_c_xy_j;

                        S_XY(related_Box_q,related_Box_db) = 10*exp_R*exp_d_xy_j*exp_P_b_q*exp_P_b_c;

                    end
               end


               S_XY_sorted = zeros(num_box,num_box);
               C_j_nn_Nr_sorted = zeros(num_box,num_box);

               for jj = 1: num_box
                   for ii = 1 : num_box
                        ii_index = C_n_n_sort_index(ii,jj);
                        S_XY_sorted(ii,jj) = S_XY(ii_index+1,jj); %51*51
                        C_j_f_sorted(ii,jj) = C_j_f(ii_index+1,jj);
                        C_j_nn_sorted(ii,jj) = C_j_nn(ii_index+1,jj);
                   end
               end

               P_j_S_C = S_XY_sorted.*C_j_f_sorted; 


                S1 = C_j_nn_sorted; 
                S1_mean = sum(S1(:))/nnz(S1);
                S1(S1>S1_mean) = 0;
                S2 = S1; 
                S2_mean = sum(S2(:))/nnz(S2);
                S2(S2>S2_mean) = 0;
                S3 = S2; 
                S3_mean = sum(S3(:))/nnz(S3);
                S3(S3>S3_mean) = 0;


                S1_logical = logical(S1);
                P_j_SC = P_j_S_C(1:Top_boxes,1:Top_boxes);

                min_C_n_n = C_j_nn_sorted(1:Top_boxes,1:Top_boxes);
                if (nnz(min_C_n_n) > 0)
                    min_C_n_n = min(min_C_n_n(min_C_n_n > 0));
                else
                    min_C_n_n = 0;
                end
                P_j_SM = exp_ds_pre(i,1)/exp_ds_pre_sum;
                P_j_SM = exp(-1*min_C_n_n)*P_j_SM;

                m_j_mat = P_j_SM*P_j_SC;
                mean_min_top = exp(-1.*mean(C_j_nn(1,1:10))); 


                crf_C_qc = [current_diff C_j_nn(1,1:10)];%double(m_C_n_n(1,:));
                crf_M_j = m_j_mat;%double(m_C_n_n(2:11,:));
                d_c_j = ds_pre(i,1);
           end
           if ~(m_config.create_Model)
               
               if ~q_data_test_exist

                   M_j = crf_M_j';
                   M_j = reshape(M_j,1,[]);
                   m_pridict = [d_c_j crf_C_qc M_j];
                   
                   D_diff_predict_50 = predict(g_mdl.mdls{1},m_pridict);
                   D_diff_predict_100 = predict(g_mdl.mdls{2},m_pridict);
                   data_test = [data_test; D_diff_predict_50 D_diff_predict_100];
 
               else
               
                D_diff_predict_50 = data_test(i,1);
                D_diff_predict_100 = data_test(i,2);
               end
               %store ds_pre
               ds_new_top(i,1) = ds_pre(i,1);
               ds_new_top(i,2) =  abs(ds_pre(i,1)-m_alpha*log(D_diff_predict_50));   
               ds_new_top(i,3) =  abs(ds_pre(i,1)-m_alpha*log(D_diff_predict_100));   
       
                 
               m_table = [];
               C_n_n = [];
           else
                 crf_y = int8(gt_top(i,1))+1;         %  for PARIS
                 crf_data = struct ('Y', crf_y,'H', crf_C_qc,'X', crf_M_j, 'pre', d_c_j); 
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
               
%               gt_top = logical(isPos(iTest, ids_new));
               if(strcmp(m_config.test_on,'oxford') || strcmp(m_config.test_on,'holidays') || strcmp(m_config.test_on,'paris'))
                    isIgnore= ismember(ids_new, db.ignoreIDs{iTestSample});
                    ids_new= ids_new(~isIgnore);
                   % making 100 total
                   if size(ids_new,1) < total_top
                      differnce_ids =  total_top-size(ids_new,1);
                       for ids_i = 1:differnce_ids
                           ids_new = [ids_new ;ids_new(ids_i,1)];
                           ds_pre = [ds_pre ;ds_pre(ids_i,1)];
                       end
                   end
                    isPos= ismember(ids_new', db.posIDs{iTestSample});
                    gt_top = isPos';
                    thisRecall= cumsum(isPos') > 0; % yahan se get karta hai %db.cp (close position)
               else
                    gt_top = isPos(iTest, ids_new);
                    thisRecall= cumsum( isPos(iTest, ids_new) ) > 0; % yahan se get karta hai %db.cp (close position)    
               end
               
               
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
           
           if show_output % && display_thumb(1,2) ~= 1 && display_thumb(1,6) == 1
              
               for j = 1:5
                    %netvlad = imread(netvlat_img(j,1));
                    netvlad = imread(strcat(dataset_path,db.dbImageFns{display_thumb(j,1),1}));

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

           
                disp('Press any key to continue !') 
                pause;    
           end
           
        else
            allrecalls_m = [];
        end
        if iTestSample == m_limit && m_config.create_Model
            break;
        end
        if ~q_data_test_exist

            % check folder
            check_folder = fileparts(q_data_test);
            if ~exist(check_folder, 'dir')
                mkdir(check_folder)
            end
            save(q_data_test,'data_test');
            data_test = [];
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
        fprintf( 'NS    NetVLAD   MAQBOOL_50  MAQBOOL_100   \n')
        fprintf( '__________________________________________\n')

        relja_display('%03d   %.4f    %.4f      %.4f\n', [ns(:), mean(recalls,1)', mean(recalls_m(:,:,1),1)',mean(recalls_m(:,:,2),1)']');
        
        
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