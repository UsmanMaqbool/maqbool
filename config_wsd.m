function m_opts= config_wsd(paths)
    
    % Controlling parameters

    iTestSample_Start= 1; % Testing Images Index
    startfrom = 1;        % NetVLAD recall images index  
    
    show_output = 1;      % To show the output thumbnails (it requires adding breakpoints on line 430 of m_recallAtN.m file
    proj = 'm'; 
    f_dimension = 512;   % '512' or '4096'
    pre_net = 'vd16';
    net_dataset = 'pitts30k'; % tokyoTM', 'pitts30k' (pre-trained model)
    job_net = strcat(pre_net,'_',net_dataset); 
    job_datasets = 'pitts30k';  %'pitts30k' , 'tokyo247' (Test on)
    
    m_on = 'tokyoTM'; % MAQBOOL DT Model created using TokyoTM test dataset.
    m_limit = 250; % use ground truth till 250 of `m_on` for creating decision tree
    
    m_directory = paths.m_directory; % Save MAQBOOL files
    
    if f_dimension == 4096
        m_alpha = 0.31;
    else
        m_alpha = 1.15;
    end
    
 
    %%

    if strcmp(job_net,'vd16_pitts30k')
        % PITTSBURGH DATASET
       netID= 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white';
    elseif strcmp(job_net,'vd16_tokyoTM')
        % TOKYO DATASET
        netID= 'vd16_tokyoTM_conv5_3_vlad_preL2_intra_white';
    end

    if strcmp(job_datasets,'pitts30k')
        dbTest= dbPitts('30k','test');
        datasets_path =  paths.dsetRootPitts;
        query_folder = 'queries';
    elseif strcmp(job_datasets,'tokyo247')
        dbTest= dbTokyo247();
        datasets_path = paths.dsetRootTokyo247; 
        query_folder = 'query';
    end
    
    save_path = strcat(m_directory,job_net,'_to_',job_datasets,'_',int2str(f_dimension),'_',proj);
    save_m_on = strcat(m_directory,job_net,'_to_',m_on,'_',int2str(f_dimension),'_',proj);
    save_m_data = strcat(m_directory,'models/',job_net,'_to_',m_on,'_',int2str(f_dimension),'_data.mat');
    save_m_data_mdl = strcat(m_directory,'models/', job_net,'_to_',m_on,'_',int2str(f_dimension),'_mdls.mat');
    save_m_data_test = strcat(m_directory,'data_test/',job_net,'_to_',job_datasets,'_',int2str(f_dimension));

    save_path_all = strcat(m_directory,job_net,'_to_',job_datasets,'_box_50_plus','.mat');
        
    % Save result for tikz latex
    m_results_50_fname = strcat('results/',job_net,'_to_',job_datasets,'_maqbool_DT_50_',int2str(f_dimension),'.dat');
    m_results_100_fname = strcat('results/',job_net,'_to_',job_datasets,'_maqbool_DT_100_',int2str(f_dimension),'.dat');
    netvlad_results_fname = strcat('results/',job_net,'_to_',job_datasets,'_netvlad_',int2str(f_dimension),'.dat');
    save_results = strcat('results/',job_net,'_to_',job_datasets,'_both_results_',int2str(f_dimension),'.mat');
    plot_title = strcat(job_net,'_to_',job_datasets,'_',int2str(f_dimension));

    %%
    m_opts = struct(...
                'm_directory',              m_directory, ...
                'netID',                    netID, ...
                'proj',                     proj, ...
                'job_net',                  job_net, ...
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
                'dbTest',                   dbTest, ...
                'cropToDim',                f_dimension, ...
                'm_on',                     m_on, ....    
                'create_Model',             0 ...
                );


end
