function model_wsd(m_config) 
    
    fprintf( 'Creating m Model \n')

    load(m_config.save_m_data,'data');
    
    HH = [];
    for i = 1:size(data,2)
        XX = data(i).X';
        XX = reshape(XX,1,[]);
        HH = [HH ; data(i).pre data(i).H XX double(data(i).Y)];
    end
    GT = HH(1:25000,:);
    paroptions = statset('UseParallel','Always');
    
    Data = array2table(GT);
    mdls{1} = TreeBagger(50,Data,'GT113','Method','regression','OOBPrediction','On');  
    mdls{2} = TreeBagger(100,Data,'GT113','Method','regression', 'OOBPrediction','On');  
    save(m_config.save_m_data_mdl,'mdls');
    fprintf( 'm Model is created. \n')
end