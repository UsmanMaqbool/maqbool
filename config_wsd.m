function m_opts= config_wsd(paths)
    
    % Controlling parameters

    % Select feature dimension
    f_dimension = 512;   % '512' or '4096'
    
    
    if f_dimension == 4096
        m_alpha = 0.31;
    else
        m_alpha = 1.15;
    end

    
    pre_net = 'vd16';
    
    % Select pre-trained model
    net_dataset = 'pitts30k'; % tokyoTM', 'pitts30k'
    job_net = strcat(pre_net,'_',net_dataset);
    
    % Test model on
    test_on = 'pitts30k';  %'pitts30k' , 'tokyo247' , 'oxford', 'paris'
    
    m_on = 'tokyoTM'; % MAQBOOL DT Model created using TokyoTM test dataset.
    
    m_directory = paths.m_directory; % Save MAQBOOL files
    
    %%
    
    m_limit = 250; % use ground truth till 250 of `m_on` for creating decision tree
    show_output = 0;      % To show the output thumbnails (it requires adding breakpoints on line 430 of m_recallAtN.m file
    proj = 'm'; 
    
    if strcmp(job_net,'vd16_pitts30k')
        % PITTSBURGH DATASET
       netID= 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white';
    elseif strcmp(job_net,'vd16_tokyoTM')
        % TOKYO DATASET
        netID= 'vd16_tokyoTM_conv5_3_vlad_preL2_intra_white';
    end

    if strcmp(test_on,'pitts30k')
        dbTest= dbPitts('30k','test');
        datasets_path =  paths.dsetRootPitts;
        image_folder = 'images';
        query_folder = 'queries';
    elseif strcmp(test_on,'tokyo247')
        dbTest= dbTokyo247();
        datasets_path = paths.dsetRootTokyo247; 
        image_folder = 'images';
        query_folder = 'query';
    elseif strcmp(test_on,'oxford')
        dsetName= 'ox5k';
        useROI= false;
        if useROI
            lastConvLayer= find(ismember(relja_layerTypes(net), 'custom'),1)-1; % Relies on the fact that NetVLAD, Max and Avg pooling are implemented as a custom layer and are the first custom layer in the network. Change if you use another network which has other custom layers before
            netBottom= net;
            netBottom.layers= netBottom.layers(1:lastConvLayer);
            info= vl_simplenn_display(netBottom);
            clear netBottom;
            recFieldSize= info.receptiveFieldSize(:, end);
            assert(recFieldSize(1) == recFieldSize(2));% we are assuming square receptive fields, otherwise dbVGG needs to change to account for non-square
            recFieldSize= recFieldSize(1);
            strMode= 'crop';
        else
            recFieldSize= -1;
            strMode= 'full';
        end

        dbTest= dbVGG(dsetName, recFieldSize);
        %dbTest= dbVGG('ox5k');
        datasets_path = paths.dsetRootOxford; 
        query_folder = 'images';
        image_folder = 'images';
    elseif strcmp(test_on,'paris')
        dbTest= dbVGG('paris');
        datasets_path = paths.dsetRootParis; 
        query_folder = 'images';
        image_folder = 'images';
    end
    
    save_path = strcat(m_directory,job_net,'_to_',test_on,'_',int2str(f_dimension),'_',proj);
    save_m_on = strcat(m_directory,job_net,'_to_',m_on,'_',int2str(f_dimension),'_',proj);
    save_m_data = strcat(m_directory,'models/',job_net,'_to_',m_on,'_',int2str(f_dimension),'_data.mat');
    save_m_data_mdl = strcat(m_directory,'models/', job_net,'_to_',m_on,'_',int2str(f_dimension),'_mdls.mat');
    save_m_data_test = strcat(m_directory,'data_test/',job_net,'_to_',test_on,'_',int2str(f_dimension));

    save_path_all = strcat(m_directory,job_net,'_to_',test_on,'_box_50_plus','.mat');
        
    % Save result for tikz latex
    m_results_50_fname = strcat('results/',job_net,'_to_',test_on,'_maqbool_DT_50_',int2str(f_dimension),'.dat');
    m_results_100_fname = strcat('results/',job_net,'_to_',test_on,'_maqbool_DT_100_',int2str(f_dimension),'.dat');
    netvlad_results_fname = strcat('results/',job_net,'_to_',test_on,'_netvlad_',int2str(f_dimension),'.dat');
    save_results = strcat('results/',job_net,'_to_',test_on,'_both_results_',int2str(f_dimension),'.mat');
    plot_title = strcat(job_net,'_to_',test_on,'_',int2str(f_dimension));
        
    iTestSample_Start= 1; % Testing Images Index
    startfrom = 1;        % NetVLAD recall images index  

    %%
    m_opts = struct(...
                'm_directory',              m_directory, ...
                'netID',                    netID, ...
                'proj',                     proj, ...
                'job_net',                  job_net, ...
                'test_on',                  test_on, ...
                'datasets_path',            datasets_path, ...
                'plot_title',               plot_title, ...
                'save_path',                save_path, ...
                'save_results',             save_results, ...
                'save_path_all',            save_path_all, ...
                'save_m_data_test',         save_m_data_test, ...
                'm_limit',                  m_limit, ...
                'save_m_on',                save_m_on, ...
                'm_alpha',                  m_alpha, ...
                'save_m_data',              save_m_data, ...
                'save_m_data_mdl',          save_m_data_mdl, ...
                'm_d_results_fname',        m_results_50_fname, ...
                'm_r_results_fname',        m_results_100_fname, ...
                'netvlad_results_fname',    netvlad_results_fname, ...
                'vt_type',                  3, ...
                'iTestSample_Start',        iTestSample_Start, ...
                'startfrom',                startfrom, ...
                'show_output',              show_output, ...
                'query_folder',             query_folder, ...
                'image_folder',             image_folder, ...
                'dbTest',                   dbTest, ...
                'cropToDim',                f_dimension, ...
                'm_on',                     m_on, ....    
                'create_Model',             0 ...
                );


end
