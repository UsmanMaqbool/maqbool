function m_model(m_config) 
    
    fprintf( 'Creating m Model \n')

    load(m_config.save_m_data,'data');
    
    HH = [];
    for i = 1:size(data,2)
        XX = data(i).X';
        XX = reshape(XX,1,[]);
        HH = [HH ; data(i).pre data(i).H XX double(data(i).Y)];
    end
    GT = sortrows(HH,112);
    % GT = GTHH(1:nnz(HH== 1)*4,:);
    
    Data = array2table(GT);
    hypopts = struct('ShowPlots',false,'Verbose',0,'UseParallel',false);

   % Decision tree
   mdls{1} = fitctree(Data,'GT112', ...
       'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions', hypopts);

  % Random fitrensemble (Works better with 512 Dimension)
    mdls{2} = TreeBagger(50,Data,'GT112','Method','regression',...
    'OOBPrediction','On');    
  %  
    
    save(m_config.save_m_data_mdl,'mdls');
    fprintf( 'm Model is created. \n')
end