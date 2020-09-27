function m_model(m_config) 
    
    fprintf( 'Creating m Model \n')

    load(m_config.save_m_data,'data');
    HH = [];
    for i = 1:size(data,2)
        XX = data(i).X';
        XX = reshape(XX,1,[]);
        HH = [HH ; data(i).pre data(i).H XX double(data(i).Y)];
    end
    Data = array2table(HH);
    hypopts = struct('ShowPlots',false,'Verbose',0,'UseParallel',false);

    % Decision tree
    %mdls{1} = fitctree(Data,'HH112', ...
     %   'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions', hypopts);
  
    mdls{1} = fitctree(Data,'HH112', 'OptimizeHyperparameters','auto');
    
    
    
    mdls{2} = fitrensemble(Data,'HH112');
    
   
%   mdls{1} = fitcnb(Data,'HH112', ...
 %   'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions', hypopts);

    %mdls{1} = fitctree(Data,'HH112', 'OptimizeHyperparameters','auto');
   % mdls{1} = fitctree(Data,'HH112', ...
    %    'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions', hypopts);

    

  %  mdls{2} = fitrensemble(Data,'HH112');

    % Naive Bayes

    % mdls{3} = fitcnb(Data,'HH112', ...
    %     'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions', hypopts);

    
    
    
  % Random fitrensemble (Works better with 512 Dimension)
    mdls{3} = TreeBagger(50,Data,'HH112','Method','regression',...
    'OOBPrediction','On');

    
    save(m_config.save_m_data_mdl,'mdls');
    fprintf( 'm Model is created. \n')
end